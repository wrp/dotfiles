# Startup file for interactive login shells
case $- in
*i*) test -n "$BASH" && test -f $HOME/.bashrc && . $HOME/.bashrc;;
esac
