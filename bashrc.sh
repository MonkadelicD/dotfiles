# Note: there is no shebang in this script. This script sets my preferred shell
# configuration and should be able to be sourced from any Bash-like shell or
# from Z shell.

set -x
# If we are not running interactively do not continue loading this file.
case $- in
    *i*) ;;
      *) return;;
esac

# source any files in our ~/dotfiles/bashrc.d directory
if [ -x .bashrc.d ]; then
  for bashrc_file in .bashrc.d/*; do
    [ -r "$bashrc_file" ] && source "$bashrc_file"
  done
  unset bashrc_file
fi

set +x
