# alias to update, dist-upgrade, autoremove, and autoclean if os is Debian, Ubuntu, or Linux Mint
if [[ -e /etc/os-release ]]; then
	source /etc/os-release;
	os="$ID"
fi

if [[ $ID == "ubuntu" ]] || [[ $ID == "debian" ]] || [[ $ID == "linuxmint" ]]; then
	alias uu='echo "Updating package repositories..."; sudo apt update && echo "Performing dist-upgrade..."; sudo apt -y upgrade && echo "Removing unecessary packages..."; sudo apt -y autoremove && echo "Cleaning up local package repositories..."; sudo apt -y autoclean'
fi

# git management of dot files
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# git management for mcstart
alias mcgit='/usr/bin/git --git-dir=$HOME/.mcstart --work-tree=$HOME/scripts'

# customized default ls aliases
alias ll='ls -hal'
alias la='ls -Ah'
alias l='ls -CFh'

# call custom tmux layouts
alias tmux-work='tmux new-session "tmux source-file ~/.tmux/at-work"'
alias tmux-home='tmux new-session "tmux source-file ~/.tmux/at-home"'
alias tmux='tmux new-session "tmux source-file ~/.tmux/default"'

# use python3
alias python='python3'

