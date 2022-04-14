# Startup file for login shells
case $- in
*i*) test -n "$BASH" && test -f $HOME/.bashrc && . $HOME/.bashrc;;
esac
