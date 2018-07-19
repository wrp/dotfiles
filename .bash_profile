# Startup file for login shells
case "$-" in
*i*) test -f $HOME/.bashrc && . $HOME/.bashrc;;  # interactive
esac
