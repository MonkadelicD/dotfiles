#!/bin/bash
## setupdotfiles.sh
## Automate configuration of dotfiles, ie:
## create .bashrc.d if not present and place bash customizations
## there. Also add stanza to .bashrc to look in .bashrc.d if not present
set -x

## BEGIN VARIABLES
dtfls_rc_add="[ -r ~/.myshell ] && source ~/.myshell"

# create variables to hold markers for config blocks managed by this script
dtfls_mng_head="### BEGIN DOTFILES MANAGED BLOCK"
dtfls_mng_tail="### END DOTFILES MANAGED BLOCK"

# Get OS info to determine package manager
if [ -e /etc/os-release ]; then
  source /etc/os-release;
fi
if [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]] || [[ "$ID" == "linuxmint" ]]; then
  pkg_mngr="apt"
elif [[ "$ID" == "fedora" ]] || [[ "$ID" == "rhel" ]]; then
  pkg_mngr="dnf"
else
  echo "Untested OS. Please verify and improve this script."
  exit 1
fi

script_dir=$(dirname "$0")

## END VARIABLES

## BEGIN FUNCTIONS

# DNF check for upgradable packages and install the package passed as an argument
run_dnf () {
sudo dnf check-update && sudo dnf install -y "$1"
}

# APT check for upgradable packages and install the package passed as an argument
run_apt () {
sudo apt update && sudo apt install -y "$1"
}

## END FUNCTIONS

## BEGIN PREREQUISITES

if [[ ! "$(which git)" ]]; then
  if [ "$pkg_mngr" == apt ]; then
    run_apt git
  elif [ "$pkg_mngr" == dnf ]; then
    run_dnf git
  fi
fi
if [[ ! "$(which vim)" ]]; then
  if [ "$pkg_mngr" == apt ]; then
    run_apt vim 
  elif [ "$pkg_mngr" == dnf ]; then
    run_dnf vim
  fi
fi

## END PREREQUISITES

## START BASH CUSTOMIZATIONS

# Change to directory containing dotfiles
if [ "$script_dir" != "$PWD" ]; then
  cd "$script_dir" || { echo "Failed changing directory to $script_dir"; exit 1; }
fi

# Create an array of custom bash config files
bashrc_configs=("$(ls -1 bashrc.*)")

if [ "${#bashrc_configs[@]}" -gt 0 ]; then
  # Create dirctory for custom user bash settings.
  if [ -e "$HOME"/.bashrc ]; then

  # if the following block isn't present insert it
  # this is taken from the default user .bashrc in Fedora 32
    grep "$dtfls_mng_head" "$HOME"/.bashrc
    bashrc_already_modified=$?
    if [ "$bashrc_already_modified" -gt 0 ]; then
      echo "$dtfls_mng_head" >> "$HOME"/.bashrc
      echo "$dtfls_rc_add" >> "$HOME"/.bashrc
      echo "$dtfls_mng_tail" >> "$HOME"/.bashrc
    else
      # change the text between the markers but leave the markers
      sed -i  "s/($dtfls_mng_head\\n).*(\\n$dtfls_mng_tail)/\$1$dtfls_rc_add\$2/s" "$HOME"/.bashrc
    fi
  fi
fi

# create or replace a softlink to our bashrc.sh script and config file directory
ln -sf "$HOME/dotfiles/bashrc.sh" "$HOME/.bashrc.sh"
ln -sf "$HOME/dotfiles/shell.d" "$HOME/.shell.d"
## END BASH CUSTOMIZATIONS

## START TMUX CUSTOMIZATIONS

# Create an array of tmux config files
tmux_configs=("$(ls -1d .tmux*)")

# Find all tmux related stuff
if [ "${#tmux_file[@]}" -gt 0 ]; then
  # loop through each item found
  for tmux_file in "${tmux_configs[@]}"; do
    # if it's a directory copy recursively
    if [ -d "$tmux_file" ]; then
      cp -r "$tmux_file" "$HOME"/
    # otherwise copy each file
    else
      cp "$tmux_file" "$HOME"/
    fi
  done
fi

## END TMUX CUSTOMIZATIONS

## BEGIN VIM CUSTOMIZATIONS

# copy vimrc file if present
if [ -f .vimrc ]; then
  cp .vimrc "$HOME"/
fi

# if .vim directory is missing create it and the vendor and plugins directory trees
if [ ! -d "$HOME"/.vim ]; then
  mkdir -p "$HOME"/.vim/pack/{plugins,vendor}/start
fi

# install indentLine vim plugin
rm -rf ~/.vim/pack/vendor/start/indentLine
git clone https://github.com/Yggdroot/indentLine.git ~/.vim/pack/vendor/start/indentLine
vim -u NONE -c "helptags  ~/.vim/pack/vendor/start/indentLine/doc" -c "q"

# install vim-terraform plugin
rm -rf ~/.vim/pack/plugins/start/vim-terraform
git clone https://github.com/hashivim/vim-terraform.git ~/.vim/pack/plugins/start/vim-terraform

## END VIM CUSTOMIZATIONS
set +x
