# Startup file for interactive non-login shells

# This is getting read for non-interactive shells via ssh
# From bash(1):
#     Bash  attempts  to  determine  when it is being run with its standard
#     input connected to a network connection, as when executed by the
#     remote shell daemon, usually rshd, or the secure shell daemon sshd.
#     If bash determines it is being run in this fashion, it reads  and
#     executes  commands  from ~/.bashrc  and  ~/.bashrc,  if these files
#     exist and are readable.  It will not do this if invoked as sh.  The
#     --norc option may be used to inhibit this behavior, and the --rcfile
#     option may be used to force another file to be read, but neither
#     rshd nor sshd  generally  invoke  the  shell  with those options
#     or allow them to be specified.

case "$-" in
*i*) # interactive shell
        ;;
*)
	return 0
        ;;
esac


export HISTCONTROL=ignoredups
set -o vi
shopt -s histappend
shopt -s cmdhist
shopt -s checkwinsize
shopt -s histverify
# set +H      # disable history expansion

test -x /usr/bin/lesspipe && eval "$(SHELL=/bin/sh lesspipe)"

PS1='\[$(
	# Colorize based on previous command status
		{ test $? != 0 && tput setaf 1 || tput setaf 2; } 2> /dev/null
		)\]$(
	# Marker if running in a docker image
		printf "%s" "${DOCKER+ ** $DOCKER ** }";
	# Wall clock
		)\D{%T}\[$(
	# Set rotating color schemd (rotates color on cd)
		tput setaf ${COLORS:$color_index:1} 2> /dev/null
		)\]$(
	# project
		echo "${PROJECT:+(}${PROJECT%-[0-9]*}${PROJECT:+)}";
		)$(
	# hostname
		test "${COLUMNS:-0}" -gt 140 && printf "%s" "$(uname -n \
			| cut -d. -f1 \
			| cut -b 1-20 | sed -E -e "/${USER}-[0-9A-Z]{7}./d" )"
		)$(
	# directory and git branch
		if test "${COLUMNS:-0}" -gt 40; then printf "[%s%s]" \
			"$(pwd 2> /dev/null | sed -E -e "s/.*(..........)/\1/" )" \
			"$( git rev-parse --abbrev-ref HEAD 2> /dev/null \
				| sed -E -e "s@^heads/@@" \
				-e "s/^/:/" -e "s/(...........).*/\1/" )"
		else printf :
		fi
	)'"\[$(tput setaf 2 2> /dev/null)\]$$\$ "

read_file() { for f; do if test -f "$f"; then . "$f"; fi; done; }
complete -r
complete -r gsutil 2> /dev/null
complete -r gcloud 2> /dev/null
complete -r bq 2> /dev/null
read_file $HOME/.bash-functions $HOME/.bash-interactive-functions $HOME/.bash-completions

append_var PATH $HOME/.scripts
append_var PATH $HOME/all/bin
prepend_var PATH $HOME/$(uname -m)/$(uname -s)/bin
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
		echo "WARNING: $HISTFILE (bash history file) is empty!  Removing."
		rm "$HISTFILE"
	fi
	if test "$IFS" != $' \t\n'; then
		echo "WARNING: IFS contains unexpected characters" >&2
	fi
	test -f "$HISTFILE" || history -w
	if ! test -f "$HISTFILE"; then
		echo "WARNING: $HISTFILE (bash history file) does not exist"
	fi
	history -a || echo 'WARNING: history -a failed'
} >&2

after_cmd() {
	# Run after a command, and before a prompt is displayed
	local _status=$?
	report_cmd_status $HISTFILE $_status >> $HOME/.bash-history
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
		s/[ \t]+$//;
		print unless $. == 1; # Delay printing of timestamp
	'
}

trap archive 0
trap debug_trap DEBUG
trap '. $HOME/.bashrc' SIGUSR1


PROMPT_COMMAND='after_cmd'
