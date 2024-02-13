# Startup file for interactive (or non-interactive with --login) login shells

case $- in
*i*) test -n "$BASH" && test -f "$HOME"/.bashrc && . "$HOME"/.bashrc;;
esac
