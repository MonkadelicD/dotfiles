#!/bin/bash
## setupdotfiles.sh
## Automate configuration of dotfiles, ie:
## create .bashrc.d if not present and place bash customizations
## there. Also add stanza to .bashrc to look in .bashrc.d if not present

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

# get os info
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

if [[ ! $(which git) ]]; then
  if [ "$pkg_mngr" == apt ]; then
    run_apt git
  elif [ "$pkg_mngr" == dnf ]; then
    run_dnf git
  fi
fi
if [[ ! $(which vim) ]]; then
  if [ "$pkg_mngr" == apt ]; then
    run_apt vim 
  elif [ "$pkg_mngr" == dnf ]; then
    run_dnf vim
  fi
fi

## END PREREQUISITES

## START BASH CUSTOMIZATIONS

# Create an array of custom bash config files
bashrc_configs=("$(ls -1A .bash*)")

if [ "${#bashrc_configs[@]}" -gt 0 ]; then
  # Create dirctory for custom user bash settings.
  if [ -e "$HOME"/.bashrc ]; then
    if [ ! -d "$HOME"/.bashrc.d ]; then
      mkdir "$HOME"/.bashrc.d || { echo "Error creating directory: $HOME/.bashrc.d"; exit 1; }
    fi

  # this is taken from the default user .bashrc in Fedora 32
    cat << 'EOF' >> "$HOME"/.bashrc
## BEGIN BLOCK BY SETUPDOTFILES.SH
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
## END BLOCK BY SETUPDOTFILES.SH
EOF
  fi

  # copy bash files to .bashrc.d directory
  for rc_file in ${bashrc_configs[@]}; do
    # if the file already exists, remove it first.
    if [ -e "$HOME"/"$rc_file" ]; then
      rm -rf "$HOME"/"$rc_file"
    fi
    cp "$rc_file" "$HOME"/.bashrc.d/ ||  { echo "Error copying $rc_file to $HOME/.bashrc.d"; exit 1; }
  done
fi

## END BASH CUSTOMIZATIONS

## START TMUX CUSTOMIZATIONS

# Create an array of tmux config files
tmux_configs=("$(ls -1d .tmux*)")

# Find all tmux related stuff
if [ "${#tmux_file[@]}" -gt 0 ]; then
  # loop through each item found
  for tmux_file in ${tmux_configs[@]}; do
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
git clone https://github.com/Yggdroot/indentLine.git ~/.vim/pack/vendor/start/indentLine
vim -u NONE -c "helptags  ~/.vim/pack/vendor/start/indentLine/doc" -c "q"

# install vim-terraform plugin
git clone https://github.com/hashivim/vim-terraform.git ~/.vim/pack/plugins/start/vim-terraform

## END VIM CUSTOMIZATIONS
