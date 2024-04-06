# alias to update, dist-upgrade, autoremove, and autoclean if os is Debian, Ubuntu, or Linux Mint
if [[ -e /etc/os-release ]]; then
	source /etc/os-release;
	os="$ID"
fi

if [[ $ID == "ubuntu" ]] || [[ $ID == "debian" ]] || [[ $ID == "linuxmint" ]]; then
	alias uu='echo "Updating package repositories..."; sudo apt update && echo "Performing dist-upgrade..."; sudo apt -y upgrade && echo "Removing unecessary packages..."; sudo apt -y autoremove && echo "Cleaning up local package repositories..."; sudo apt -y autoclean'
elif [[ $ID == "fedora" ]] || [[ $ID == "rhel" ]]; then
  alias uu='echo "Updating package repositories..."; sudo dnf check-update && echo "Performing package upgrades..."; sudo dnf upgrade -y && echo "Removing unecessary packages..."; sudo dnf autoremove -y'
fi

# git management of dot files
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# git management for mcstart
alias mcgit='/usr/bin/git --git-dir=$HOME/.mcstart --work-tree=$HOME/scripts'

# git management of hib terraform
alias hib-git='/usr/bin/git --git-dir=/home/daryl/lanshares/sharedata/Daryl/terraform/.git-hib-setup/ --work-tree=/home/daryl/lanshares/sharedata/Daryl/terraform/'

# customized default ls aliases
alias ll='ls -hal'
alias la='ls -Ah'
alias l='ls -CFh'

# call custom tmux layouts
alias tmux-work='tmux new-session -s "Ds-Work" -n SysAdmin'
alias tmux-home='tmux new-session -s "Ds-Home" -n SysAdmin'
alias tmux-start='tmux new-session -s "Ds-Sess" -n SysAdmin'

# use python3
alias python='python3'

