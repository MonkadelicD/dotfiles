#!/bin/bash
## setupdotfiles.sh
## Automate configuration of dotfiles, ie:
## create .bashrc.d if not present and place bash customizations
## there. Also add stanza to .bashrc to look in .bashrc.d if not present

## BEGIN VARIABLES

# variable containing line to source customized bash script
dtfls_rc_add="[ -r ~/.bashrc.sh ] && source ~/.bashrc.sh"

if [[ $XDG_CURRENT_DESKTOP =~ .*gnome.* ]]; then
  PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default)
fi

# create variables to hold markers for config blocks managed by this script
dtfls_mng_head="### BEGIN DOTFILES MANAGED BLOCK"
dtfls_mng_tail="### END DOTFILES MANAGED BLOCK"

# Get OS info to determine package manager
if [ -e /etc/os-release ]; then
  source /etc/os-release;
fi
if [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]] || [[ "$ID" == "linuxmint" ]]; then pkg_mngr="apt"
elif [[ "$ID" == "fedora" ]] || [[ "$ID" == "rhel" ]] || [[ "$ID" == "rocky" ]]; then
  pkg_mngr="dnf"
else
  echo "Untested OS. Please verify and improve this script."
  exit 1
fi

# What is the path to this script?
script_dir=$(dirname "$0")

# VIM paths
vimIndentLinePath="$HOME"/.vim/pack/vendor/start/indentLine
vimTerraformPath="$HOME"/.vim/pack/plugins/start/vim-terraform
vimPolyglotPath="$HOME"/.vim/pack/plugins/start/vim-polyglot
vimCocVimPath="$HOME"/.vim/pack/coc/start/coc.nvim
vimDimColorSchemePath="$HOME"/.vim/pack/plugins/start/vim-dim

## END VARIABLES

## BEGIN FUNCTIONS

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

# Ensure git is installed
if [[ ! -x /usr/bin/git ]]; then
  # Install with apt or dnf
  if [ "$pkg_mngr" == apt ]; then
    run_apt git
  elif [ "$pkg_mngr" == dnf ]; then
    run_dnf git
  fi
fi

# Ensure node is present
if [[ ! $(command -v node) ]]; then
  # if not, verify nvm is present
  if [[ ! $(command -v nvm ) ]]; then
    export NVM_DIR="$HOME/.nvm" && rm -rf "$NVM_DIR" && (
    git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
    cd "$NVM_DIR"
    git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
    ) && \. "$NVM_DIR/nvm.sh"
  fi
  # install latest LTS node
  nvm install --lts
fi

# Ensure vim is installed
if [[ ! -x /usr/bin/vim ]]; then
  # install wtih apt or dnf
  if [ "$pkg_mngr" == apt ]; then
    run_apt vim 
  elif [ "$pkg_mngr" == dnf ]; then
    run_dnf vim
  fi
fi

# Ensure tmux is installed
if [[ ! -x /usr/bin/tmux ]]; then
  # install wtih apt or dnf
  if [ "$pkg_mngr" == apt ]; then
    run_apt tmux 
  elif [ "$pkg_mngr" == dnf ]; then
    run_dnf tmux
  fi
fi

# Ensure tree is installed
if [[ ! -x /usr/bin/git ]]; then
  # Install with apt or dnf
  if [ "$pkg_mngr" == apt ]; then
    run_apt tree 
  elif [ "$pkg_mngr" == dnf ]; then
    run_dnf tree
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
ln -sf "$HOME"/dotfiles/bashrc.sh "$HOME"/.bashrc.sh
# remove an existing soft link
if [ -x "$HOME"/.bashrc.d ]; then
  cp -f ./bashrc.d/* "$HOME"/.bashrc.d/
else
  ln -sf "$HOME"/dotfiles/bashrc.d "$HOME"/.bashrc.d
fi

## END BASH CUSTOMIZATIONS

## START GNOME-TERMINAL CUSTOMIZATIONS

# set gnome-terminal palette to modified solarized colors
if [ -z "$PROFILE_ID" ]; then
  gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/ palette "['#171421', '#c01c28', '#26a269', '#a2734c', '#12488b', '#a347ba', '#2aa1b3', '#d0cfcc', '#5e5c64', '#f66151', '#33da7a', '#e9ad0c', '#2a7bde', '#c061cb', '#33c7de', '#ffffff']"
fi

## END GNOME-TERMINAL CUSTOMIZATIONS

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

# install vim-terraform plugin
rm -rf "$vimTerraformPath"
git clone https://github.com/hashivim/vim-terraform.git "$vimTerraformPath"

# install vim-polyglot
rm -rf "$vimPolyglotPath"
git clone --depth 1 https://github.com/sheerun/vim-polyglot "$vimPolyglotPath"

# install coc-nvim
rm -rf "$vimCocVimPath"
git clone --branch release https://github.com/neoclide/coc.nvim.git --depth=1 "$vimCocVimPath"
vim -c "helptags $vimCocVimPath/doc/ | q"
# copy coc-settings.json
cp -f .vim/coc-settings.json "$HOME"/.vim/
cp -f .coc.vimrc "$HOME"/
# install coc language servers
vim -c "CocInstall coc-markdownlint coc-tsserver coc-json coc-html coc-css coc-pyright coc-yaml | q"

# install terraform-lsp
if [[ ! -x "$HOME"/bin/terraform-lsp ]]; then
  wget -qO- https://github.com/juliosueiras/terraform-lsp/releases/download/v0.0.12/terraform-lsp_0.0.12_linux_amd64.tar.gz | tar -xzf - -C "$HOME"/bin terraform-lsp
fi

# copy vimrc file if present
if [ -f .vimrc ]; then
  cp -f .vimrc "$HOME"/
fi

## END VIM CUSTOMIZATIONS
echo "All done!"
echo "To activeate shell customizations run:"
echo "        source ~/.bashrc.sh"
