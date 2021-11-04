# Startup file for login shells
case $- in
*i*)
	test -f $HOME/.bashrc && . $HOME/.bashrc
	tmux set-option -s @dir /usr/local/data
	;;
esac
