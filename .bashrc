
export HISTCONTROL=ignoredups
set -o vi
shopt -s histappend
shopt -s cmdhist
shopt -s checkwinsize
shopt -s histverify
# set +H      # disable history expansion

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

PS1='\[$(
	# Colorize based on previous command status
		{ test $? != 0 && tput setaf 1 || tput setaf 2; } 2> /dev/null
		)\]$(
	# Marker if running in a docker image
		test -n "$DOCKER" && printf "%s" "** Docker **";
	# Wall clock
		date +%H:%M:%S
		)\[$(
		tput setaf ${COLORS:$color_index:1} 2> /dev/null
		)\]$(
	# project
		if test -n "$PROJECT"; then echo "(${PROJECT%-[0-9]*})";
		else printf %s :; fi
		)$(
	# hostname
		test "${COLUMNS:-0}" -gt 140 && printf "%s" "$(uname -n \
			| cut -d. -f1 \
			| cut -b 1-20 | sed -E -e "/${USER}-[0-9A-Z]{7}./d" )"
		)$(
	# directory and git branch
		if test "${COLUMNS:-0}" -gt 40; then printf "[%s:%s]" \
			"$(basename "$(git rev-parse --show-toplevel \
				2> /dev/null )" \
				| cut -b 1-10 )" \
			"$({ git rev-parse --abbrev-ref HEAD 2> /dev/null \
				| grep . \
				|| echo no-git; } | cut -b 1-10 )"
		else printf :
		fi
	)'"\[$(tput setaf 2 2> /dev/null)\]$$\$ "

read_file() { for f; do test -f $f && . $f; done; }
read_file ~/.bash-functions ~/.bash-interactive-functions
complete -r

append PATH /usr/local/bin
append PATH $HOME/.scripts
append PATH $HOME/all/bin
append PATH $HOME/$(uname -m)/$(uname -s)/bin
append PATH $HOME/we-tools-cli/bin

export COLORS=356
color_index=$(expr \( "${color_index:-${#COLORS}}" + 1 \) % ${#COLORS})
export color_index

# trap ". $HOME/.ssh/agent.$(hostname)" SIGUSR2
nl='
'
PROMPT_COMMAND='tmux-title'
unset NO_COLOR
export EVENT_NOKQUEUE=1
export EMAIL=williamp@wepay.com
export LC_TIME=C  #  Get 24 hour times for %X (sar)
export HISTSIZE=1000
export HISTFILE=$HOME/.bash-history-dir/shell-pid-$$
# unset HISTFILESIZE
# Docs say unsetting HISTFILESIZE will prevent truncation.  Rumor is it does not work
export HISTFILESIZE=9999999999
# export HISTTIMEFORMAT="%h/%d - %H:%M:%S "
export HISTTIMEFORMAT='%H:%M:%S ' #%m/%d
export EDITOR=vim
export CONFIG_SITE=$HOME/CONFIG_SITE
export COLUMNS
export LESS=-FeRXS
export GIT_PAGER=less
export ACK_PAGER_COLOR=less
export PAGER=less
export PYTHONSTARTUP=$HOME/.pystartup

# environments for the local host
read_file $HOME/.bash-env


debug_trap() {
	local _status=$?
	local val
	if test "${BASH_COMMAND}" != "$PROMPT_COMMAND"; then
		return
	fi
	history -a;
	if ! test -f "$HISTFILE"; then
		exec >&2
		printf "WARNING: $HISTFILE does not exist!!  "
		printf "exec-ing a new shell\n"
		touch $HISTFILE
		exec bash
	fi
	# Clean up the command and append it to global .bash-history.
	# Note that the FAILED string is used in scripts/search-bash-history
	tac $HISTFILE | STATUS=$_status perl -pe '
		if( /^#[0-9]{10}$/ ) { # abort after adding the timestamp.
			s@([0-9]{10})@sprintf "%s (%s GMT by %d in %s)%s",
				$1,
				scalar gmtime $1,
				'"$$,
				\"$(pwd)\""',
				$ENV{STATUS} > 0 ? " FAILED" : ""
				@ge;
			print;  # Since about to skip auto print with -p
			exit 0; # Exit so we only process most recent command
		}
	' | tac | perl -ne '
		$ts = $_ if $. == 1;
		# Ignore simple commands
		if( $. == 2 && ! /;/ && ! /\\$/ && ! /\$\(/ ) {
			exit 0 if /^[a-f,h-z]( |\n)/; # single letter cmds, keep g
			exit 0 if /^[a-z]{2}$/;   # 2 letter cmds w/no args
			foreach $cmd (
					"cal", "cat", "cd", "date", "echo", "exec bash",
					"head", "less", "more", "pwd", "tail", "man"
				) {
				exit 0 if /^$cmd( |$)/ }
			print $ts
		}
		print unless $. == 1 # Delay printing of timestamp
	' >> $HOME/.bash-history
	val=$( tmux show-env 2> /dev/null |
		awk -F= '/^SSH_AUTH_SOCK=/{print $2}' )
	test -n "$val" && SSH_AUTH_SOCK="$val"
}

trap archive 0
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
# bind -m vi-insert '"jk": vi-movement-mode'

# LSCOLORS is for OSX, LS_COLORS for linux
LS_COLORS=$( cat << EOF | tr \\n :
rs=0:di=02;33:ln=01;36:mh=00:pi=40;33:so=01;35
do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43
ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31
*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31
*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31
*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31
*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31
*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31
*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35
*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35
*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35
*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35
*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35
*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35
*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35
*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35
*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36
*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36
*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36
EOF
)

if test -f $HOME/.ssh/agent_sock && 
		test ! -z "$SSH_AUTH_SOCK" -a "$SSH_AUTH_SOCK" != "$HOME/.ssh/agent_sock"; then
	rm -f "$HOME/.ssh/agent_sock" 2>/dev/null
	ln -fs "$SSH_AUTH_SOCK" "$HOME/.ssh/agent_sock"
	export SSH_AUTH_SOCK="$HOME/.ssh/agent_sock"
fi
