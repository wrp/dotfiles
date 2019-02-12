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
		if test "${COLUMNS:-0}" -gt 40; then printf "[%s%s]" \
			"$(pwd | sed -E -e "s/.*(..........)/\1/" )" \
			"$( git rev-parse --abbrev-ref HEAD 2> /dev/null \
				| sed -E -e "s@^heads/@@" \
				-e "s/^/:/" -e "s/(...........).*/\1/" )"
		else printf :
		fi
	)'"\[$(tput setaf 2 2> /dev/null)\]$$\$ "

read_file() { for f; do test -f "$f" && . "$f"; done; }
read_file $HOME/.bash-functions $HOME/.bash-interactive-functions
complete -r

append PATH $HOME/.scripts
append PATH $HOME/all/bin
append PATH $HOME/$(uname -m)/$(uname -s)/bin
read_file $HOME/.bash-env
test -z "$HISTFILE" && HISTFILE=$HOME/.bash-history-$$
export HISTFILE
if ! test -s "$HISTFILE"; then
	{ printf '#'; date +%s; echo ": Shell $$ begins"; } >> $HISTFILE
fi

read_file $HOME/.bash-local

debug_trap() {
	# Runs before a command in an interactive shell
	if test -f "$HISTFILE" && ! test -s "$HISTFILE"; then
		echo "WARNING: $HISTFILE (bash history file) is empty!  Removing." >&2
		rm "$HISTFILE"
	fi
	if ! test -f "$HISTFILE"; then
		history -w ||
			echo 'WARNING: history -w failed'
	fi
	if ! test -f "$HISTFILE"; then
		echo "WARNING: $HISTFILE (bash history file) does not exist"
	fi
	history -a || echo 'WARNING: history -a failed'
} >&2

after_cmd() {
	# Run after a command, and before a prompt is displayed
	local _status=$?
	local val
	report_cmd_status $HISTFILE $_status >> $HOME/.bash-history
	tmux-title
}

report_cmd_status() {
	# Clean up the most recent command in HISTFILE and append it to global .bash-history.
	# Note that the FAILED string is used in scripts/search-bash-history
	test -f "$1" && tac "$1" | STATUS="$2" perl -MPOSIX -pe '
		if( /^#[0-9]{10}$/ ) { # abort after adding the timestamp.
			s@([0-9]{10})@sprintf "%s (%s by pid:%d in %s%s%s) %s",
				$1,
				POSIX::strftime("%a %H:%M:%S GMT", gmtime $1),
				'"$$"',
				"'"${PWD}"'",
				"'"${PROJECT:+:}${PROJECT}"'",
				"'"${HOSTNAME:+ on }${HOSTNAME}"'",
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
