#!/bin/bash
## setup_bash_only.sh
## Automate configuration of dotfiles, ie:
## create .bashrc.d if not present and place bash customizations
## there. Also add stanza to .bashrc to look in .bashrc.d if not present

## BEGIN VARIABLES

# variable containing line to source customized bash script
dtfls_rc_add="[ -r ~/.bashrc.sh ] && source ~/.bashrc.sh"

# create variables to hold markers for config blocks managed by this script
dtfls_mng_head="### BEGIN DOTFILES MANAGED BLOCK"
dtfls_mng_tail="### END DOTFILES MANAGED BLOCK"

# Get OS info to determine package manager
for release_file in $(ls /etc/*release); do
  if [[ ! -h "$release_file" ]] && [[ -f "$release_file" ]]; then
    echo "Getting release info from... $release_file"
    if [ "${release_file#*"centos"}" != "$release_file" ]; then
      pkg_mngr="yum"
    else
      source "$release_file"
    fi
    if [[ -z "$ID" ]]; then
      echo "Untested OS. Please verify and improve this script."
      exit 1
    elif [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]] || [[ "$ID" == "linuxmint" ]]; then
      pkg_mngr="apt"
    elif [[ "$ID" == "fedora" ]] || [[ "$ID" == "rhel" ]] || [[ "$ID" == "rocky" ]]; then
      pkg_mngr="dnf"
    fi
  fi
done

# What is the path to this script?
script_dir=$(dirname "$0")

# VIM paths
vimIndentLinePath="$HOME"/.vim/pack/vendor/start/indentLine
vimDimColorSchemePath="$HOME"/.vim/pack/plugins/start/vim-dim

## END VARIABLES

## BEGIN FUNCTIONS

# YUM install the package passed as an argument
run_yum () {
  sudo yum install -y "$1"
}

# DNF install the package passed as an argument
run_dnf () {
sudo dnf install -y "$1"
}

# APT update package cache and install the package passed as an argument
run_apt () {
sudo apt update && sudo apt install -y "$1"
}

## END FUNCTIONS

## BEGIN PREREQUISITES

# ensure $HOME/bin exists
if [[ ! -d "$HOME"/bin ]]; then
  mkdir -p "$HOME"/bin
fi

# Ensure git is installed
if [[ ! -x /usr/bin/git ]]; then
  # Install with apt or dnf
  if [ "$pkg_mngr" == apt ]; then
    run_apt git
  elif [ "$pkg_mngr" == dnf ]; then
    run_dnf git
  elif [ "$pkg_mngr" == yum ]; then
    run_yum git
  fi
fi

# Ensure vim is installed
if [[ ! -x /usr/bin/vim ]]; then
  # install wtih apt or dnf
  if [ "$pkg_mngr" == apt ]; then
    run_apt vim
  elif [ "$pkg_mngr" == dnf ]; then
    run_dnf vim
  elif [ "$pkg_mngr" == yum ]; then
    run_yum vim
  fi
fi

# Ensure tree is installed
if [[ ! -x /usr/bin/tree ]]; then
  # Install with apt or dnf
  if [ "$pkg_mngr" == apt ]; then
    run_apt tree 
  elif [ "$pkg_mngr" == dnf ]; then
    run_dnf tree
  elif [ "$pkg_mngr" == yum ]; then
    run_yum tree
  fi
fi

# Ensure tmux is installed
if [[ ! -x /usr/bin/tmux ]]; then
  # install wtih apt or dnf
  if [ "$pkg_mngr" == apt ]; then
    run_apt tmux 
  elif [ "$pkg_mngr" == dnf ]; then
    run_dnf tmux
  elif [ "$pkg_mngr" == yum ]; then
    run_yum tmux
  fi
fi

## END PREREQUISITES

## START BASH CUSTOMIZATIONS

# Change to directory containing dotfiles
if [ "$script_dir" != "$PWD" ]; then
  cd "$script_dir" || { echo "Failed changing directory to $script_dir"; exit 1; }
  script_dir="$PWD"
fi

# Create an array of custom bash config files
bashrc_configs=("$(ls -1 bashrc.*)")

if [ "${#bashrc_configs[@]}" -gt 0 ]; then
  # Create dirctory for custom user bash settings.
  if [ -e "$HOME"/.bashrc ]; then

  # if the following block isn't present insert it
  # this is taken from the default user .bashrc in Fedora 32
    grep -q "$dtfls_mng_head" "$HOME"/.bashrc
    bashrc_already_modified=$?
    if [ "$bashrc_already_modified" -gt 0 ]; then
      echo "$dtfls_mng_head" >> "$HOME"/.bashrc
      echo "$dtfls_rc_add" >> "$HOME"/.bashrc
      echo "$dtfls_mng_tail" >> "$HOME"/.bashrc
    else
      # delete managed block if found
      sed -i "/$dtfls_mng_head/,/$dtfls_mng_tail/{/.*/d;}" "$HOME"/.bashrc
      # write the managed block back in with header and footer markers
      echo "$dtfls_mng_head" >> "$HOME"/.bashrc
      echo "# source my custom bash stuffs" >> "$HOME"/.bashrc
      echo "$dtfls_rc_add" >> "$HOME"/.bashrc
      echo "$dtfls_mng_tail" >> "$HOME"/.bashrc
    fi
  fi
fi

# create or replace a softlink to our bashrc.sh script and config file directory
# remove an existing soft link
if [ -h "$HOME"/.bashrc.sh ]; then
  unlink "$HOME"/.bashrc.sh
fi
ln -sf "$scritp_dir"/bashrc.sh "$HOME"/.bashrc.sh
# remove an existing soft link
if [ -x "$HOME"/.bashrc.d ]; then
  cp -f ./bashrc.d/* "$HOME"/.bashrc.d/
else
  ln -sf "$scritp_dir"/bashrc.d "$HOME"/.bashrc.d
fi

## END BASH CUSTOMIZATIONS

## START TMUX CUSTOMIZATIONS

# Create an array of tmux config files
tmux_configs=($(ls -1d .tmux*))

# Find all tmux related stuff
if [ "${#tmux_configs[@]}" -gt 0 ]; then
  # loop through each item found
  for tmux_file in "${tmux_configs[@]}"; do
    # if it's a directory copy recursively
    if [ -d "$tmux_file" ]; then
      cp -fr "$tmux_file" "$HOME"/
    # otherwise copy each file
    else
      cp -f "$tmux_file" "$HOME"/
    fi
  done
fi

## END TMUX CUSTOMIZATIONS

## BEGIN VIM CUSTOMIZATIONS

# install vim-dim colorscheme
rm -rf "$vimDimColorSchemePath"
git clone --branch 1.x https://github.com/jeffkreeftmeijer/vim-dim.git "$vimDimColorSchemePath"

# if .vim directory is missing create it and the vendor and plugins directory trees
if [ ! -d "$HOME"/.vim ]; then
  mkdir -p "$HOME"/.vim/pack/{plugins,vendor}/start
fi

# install indentLine vim plugin
rm -rf "$vimIndentLinePath"
git clone https://github.com/Yggdroot/indentLine.git "$vimIndentLinePath"
vim -u NONE -c "helptags  $vimIndentLinePath/doc" -c "q"

# copy vimrc file if present
if [ -f .vimrc ]; then
  cp -f .vimrc "$HOME"/
fi

## END VIM CUSTOMIZATIONS

echo "All done!"
echo
echo "To use vimserver script with ranger, edit $HOME/.config/ranger/rifle.conf"
echo
echo "To activeate shell customizations run:"
echo "        source ~/.bashrc.sh"