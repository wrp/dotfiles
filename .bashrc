# Startup file for interactive non-login shells

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
		printf "%s" "${DOCKER+ ** Docker ** }";
	# Wall clock
		date +%H:%M:%S
		)\[$(
		tput setaf ${COLORS:$color_index:1} 2> /dev/null
		)\]$(
	# project
		echo "(${PROJECT%-[0-9]*})";
		)$(
	# hostname
		test "${COLUMNS:-0}" -gt 140 && printf "%s" "$(uname -n \
			| cut -d. -f1 \
			| cut -b 1-20 | sed -E -e "/${USER}-[0-9A-Z]{7}./d" )"
		)$(
	# directory and git branch
		if test "${COLUMNS:-0}" -gt 40; then printf "[%s:%s]" \
			"$(pwd | sed -E -e "s/.*(..........)/\1/" )" \
			"$({ git rev-parse --abbrev-ref HEAD 2> /dev/null \
				| grep . \
				|| echo no-git; } | cut -b 1-10 )"
		else printf :
		fi
	)'"\[$(tput setaf 2 2> /dev/null)\]$$\$ "

read_file() { for f; do test -f "$f" && . "$f"; done; }
read_file $HOME/.bash-env $HOME/.bash-functions $HOME/.bash-interactive-functions
complete -r

append PATH /usr/local/bin
append PATH $HOME/.scripts
append PATH $HOME/all/bin
append PATH $HOME/$(uname -m)/$(uname -s)/bin

read_file $HOME/.bash-local

debug_trap() {
	# Runs before a command in an interactive shell
	history -a
	if ! test -f "$HISTFILE"; then
		touch $HISTFILE && exec bash
	fi
}

after_cmd() {
	# Run after a command, and before a prompt is displayed
	local _status=$?
	local val
	report_cmd_status $HISTFILE $_status >> $HOME/.bash-history

	val=$( tmux show-env 2> /dev/null |
		awk -F= '/^SSH_AUTH_SOCK=/{print $2}' )
	test -n "$val" && SSH_AUTH_SOCK="$val"
	tmux-title
}

report_cmd_status() {
	# Clean up the most recent command in HISTFILE and append it to global .bash-history.
	# Note that the FAILED string is used in scripts/search-bash-history
	tac $1 | STATUS=$2 perl -MPOSIX -pe '
		if( /^#[0-9]{10}$/ ) { # abort after adding the timestamp.
			s@([0-9]{10})@sprintf "%s (%s by pid:%d in %s%s) %s",
				$1,
				POSIX::strftime("%a %H:%M:%S GMT", gmtime $1),
				'"$$,
				\"${PWD}\""',
				defined $ENV{PROJECT} ? ": " . $ENV{PROJECT} : "",
				$ENV{STATUS} > 0 ? "FAILED" : "ok",
				@ge;
			print;  # Since about to skip auto print with -p
			exit 0; # Exit so we only process most recent command
		}
	' | tac | perl -ne '
		$ts = $_ if $. == 1;
		if( $. == 2 )  {
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
	'
}

trap archive 0
trap debug_trap DEBUG
trap '. $HOME/.bashrc' SIGUSR1

PROMPT_COMMAND='after_cmd'
if test -f $HOME/.ssh/agent_sock && 
	test ! -z "$SSH_AUTH_SOCK" -a "$SSH_AUTH_SOCK" != "$HOME/.ssh/agent_sock"
then
	rm -f "$HOME/.ssh/agent_sock" 2>/dev/null
	ln -fs "$SSH_AUTH_SOCK" "$HOME/.ssh/agent_sock"
	export SSH_AUTH_SOCK="$HOME/.ssh/agent_sock"
fi
