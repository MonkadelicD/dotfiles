# alias to update, dist-upgrade, autoremove, and autoclean
alias uu='echo "Updating package repositories..."; sudo apt update && echo "Performing dist-upgrade..."; sudo apt -y upgrade && echo "Removing unecessary packages..."; sudo apt -y autoremove && echo "Cleaning up local package repositories..."; sudo apt -y autoclean'

# git management of dot files
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# customized default ls aliases
alias ll='ls -hal'
alias la='ls -Ah'
alias l='ls -CFh'

