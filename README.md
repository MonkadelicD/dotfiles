# Basic DOTFILES for bash

## What's it do?
This repo contains a script to add bash dotfiles customizations. It contains my preferred settings for VIM, TMUX, and some bash aliases. The settings have been tested on Ubuntu 18.04-22.04, Linux Mint 18.0-21.3, Fedora 38, RHEL 9.1-9.3

git, vim, and tmux packages will be installed if not found in /usr/bin/.

For bash, the only file that will be modified is the user's .bashrc file. A line will be added to run .bashrc.sh script which sources the aliases and bash customizations from .bashrc.d. All files stay in the dotfiles directory and soft links are created for ~/.bashrc.d and ~/.bashrc.sh

After setting up the bash stuff it moves on to tmux configs. A custom tmux theme (modified from [Ham Vocke's blog](https://hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/), a couple of custom layouts and some config customizations setup tmux how I like it. There are also some aliases in bashrc.d/bashrc.aliases for launching tmux. The tmux config will install [TPM - Tmux Plugin Manager](https://github.com/tmux-plugins/tpm), [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible), and [tmux-mem-cpu-load](https://github.com/thewtex/tmux-mem-cpu-load). These plugins are a good starting point.

Last is custom settings in .vimrc and a couple of plugins: [indnetLine](https://github.com/Yggdroot/indentLine) and [vim-terraform](https://github.com/hashivim/vim-terraform).

## Instructions for use
1. Clone this repo to your \*nix system
        git clone https://github.com/monkadelicd/dotfiles.git --depth 1
2. cd to dotfiles directory
        cd dotfiles
3. run setupdotfiles.sh
        ./setupdotfiles.sh
4. source the new bashrc stuff
        source ~/.bashrc.sh
