
export HISTCONTROL=ignoredups
set -o vi
shopt -s histappend
shopt -s cmdhist
shopt -s checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

PS1='\[$(
        { test $? != 0 && tput setaf 1 || tput setaf 2; } 2> /dev/null
	)\]$(test $COLUMNS -gt 20 &&
	    printf "%s:%d " "$(uname -n | cut -d. -f1)" "$$")\[$(
	tput setaf ${COLORS:$color_index:1} 2> /dev/null )\]$(
	set-prompt 2> /dev/null)'"\[$(tput setaf 2 2> /dev/null)\]\$ "

read_file() { for f; do test -f $f && . $f; done; }
read_file ~/.bash-functions ~/.bash-interactive-functions
complete -r

prepend PATH $HOME/$(uname -m)/bin
prepend PATH $HOME/all/bin

# We expect ~/.bashrc to be a symbolic link to .bashrc in the dotfiles
# git repo.  Find it, and add dotfiles/scripts to the path
prepend PATH $(dirname $(realpath $HOME/$(readlink $HOME/.bashrc)))/scripts

export COLORS=356
color_index=$(expr \( "${color_index:-${#COLORS}}" + 1 \) % ${#COLORS})
export color_index
cd .

# trap ". $HOME/.ssh/agent.$(hostname)" SIGUSR2
nl='
'
PROMPT_COMMAND='tmux-title'
unset NO_COLOR
export EVENT_NOKQUEUE=1
export EMAIL=williamp@wepay.com
export LC_TIME=C  #  Get 24 hour times for %X (sar)
export HISTSIZE=9999999999
export HISTFILE=$HOME/.bash-history-dir/shell-pid-$$
# unset HISTFILESIZE
# Docs say unsetting HISTFILESIZE will prevent truncation.  Rumor is it does not work
export HISTFILESIZE=9999999999
# export HISTTIMEFORMAT="%h/%d - %H:%M:%S "
export HISTTIMEFORMAT='%H:%M:%S ' #%m/%d
export EDITOR=vim
export CONFIG_SITE=$HOME/CONFIG_SITE
export COLUMNS
export LESS=-FeRX
export GIT_PAGER=less
export ACK_PAGER_COLOR=less
export PAGER=less
export PYTHONSTARTUP=$HOME/.pystartup

# environments for the local host
read_file $HOME/.bash-env


debug_trap() {
	local val
	if test "${BASH_COMMAND}" = "$PROMPT_COMMAND"; then
		history -a;
		test -f "$HISTFILE" &&
		tac $HISTFILE | sed /^#/q | tac >> $HOME/.bash-history
		val=$( tmux show-env 2> /dev/null |
			awk -F= '/^SSH_AUTH_SOCK=/{print $2}' )
		test -n "$val" && SSH_AUTH_SOCK="$val"
	fi
}

trap debug_trap DEBUG
export LSCOLORS=fxfxcxdxbxegedabagacad

# a = black, b = red, c = green, d = brown, e = blue, f = magenta, g = cyan,
# h = light grey, A = bold black, B = bold red, C = bold green, D = bold brown,
# E = bold blue, F = bold magenta, G = bold cyan, H = bold light grey
# x = default foreground or background

#  1.   directory
#  2.   symbolic link
#  3.   socket
#  4.   pipe
#  5.   executable
#  6.   block special
#  7.   character special
#  8.   executable with setuid bit set
#  9.   executable with setgid bit set
#  10.  directory writable to others, with sticky bit
#  11.  directory writable to others, without sticky bit


# Use bind -p to see a list of usefull stuff
# bind -m vi-insert '"\C-b": complete-into-braces'

if test -f $HOME/.ssh/agent_sock && 
		test ! -z "$SSH_AUTH_SOCK" -a "$SSH_AUTH_SOCK" != "$HOME/.ssh/agent_sock"; then
	rm -f "$HOME/.ssh/agent_sock" 2>/dev/null
	ln -fs "$SSH_AUTH_SOCK" "$HOME/.ssh/agent_sock"
	export SSH_AUTH_SOCK="$HOME/.ssh/agent_sock"
fi
