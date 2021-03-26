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
# But this should only be used in interactive shells, so make it explicit.
case "$-" in
*i*) # interactive shell
        ;;
*)
	return 0
        ;;
esac

# If .bashrc is from git, find the current hash.  PS1 will
# display an indicator if the shell is out of date.

if test -n "${BASH_SOURCE[0]}"; then
	__base_dir=$( dirname $(realpath "${BASH_SOURCE[0]}"  ))
	__git_version=$( cd "$__base_dir" && git describe --dirty )
fi 2> /dev/null

export HISTCONTROL=ignoredups
export IGNOREEOF=4
set -o vi
set -o physical # make pwd do the right thing w.r.t. symbolic links
shopt -s histappend
shopt -s cmdhist
shopt -s checkwinsize
shopt -s histverify
# set +H      # disable history expansion

# test -x /usr/bin/lesspipe && eval "$(SHELL=/bin/sh lesspipe)"

__RED=$(tput setaf 1)
__GREEN=$(tput setaf 2)
PS1=''
if test -n "$__RED" && test -n "$__GREEN"; then
PS1+='\[$( # Colorize based on previous command status
	{ test $? != 0 && printf "%s" "$__RED" || printf "%s" "$__GREEN"; }
	)\]'
fi
PS1+='$( # Insert asterisk if shell is out of date
	if test -n "'"$__git_version"'" &&
		test "$(cd "$__base_dir" && git describe --dirty)" != \
		"'"$__git_version"'"; then printf "* "; fi
)'
if test "$(tput cols)" -gt 80; then
	PS1+='$( # Marker if running in a docker image or dvtm
		printf "%s" "${DOCKER+ <$DOCKER> }";
		printf "%s" "${DVTM+ <dvtm> }";
	)'
	PS1+='\D{%T}'
	PS1+='\[$( # Set rotating color schema (rotates color on cd)
		tput setaf ${COLORS:$color_index:1} 2> /dev/null
		)\]'
	PS1+='$( # project
		echo "${PROJECT:+(}${PROJECT%-[0-9]*}${PROJECT:+)}";
	)'
	PS1+='$( # hostname
		test "${COLUMNS:-0}" -gt 140 && printf "%s" "$(uname -n \
			| cut -d. -f1 \
			| cut -b 1-20 | sed -E -e "/${USER}-[0-9A-Z]{7}./d" )"
	)'
	PS1+='$( # directory and git branch
		if test "${COLUMNS:-0}" -gt 40; then printf "[%10s%10s]" \
			"$(pwd 2> /dev/null | sed -E -e "s/.*(..........)/\1/" )" \
			"$( git rev-parse --abbrev-ref HEAD 2> /dev/null \
				| sed -E -e "s@^heads/@@" \
				-e "s/^/:/" -e "/(...........).*/s//\1~/" )"
		else printf :
		fi
	)'
fi
PS1+="\[$__GREEN\]$$\$ "

read_file() { for f; do if test -f "$f"; then . "$f"; fi; done; }
complete -r
complete -r gsutil 2> /dev/null
complete -r gcloud 2> /dev/null
complete -r bq 2> /dev/null
read_file $HOME/.bash-functions $HOME/.bash-interactive-functions $HOME/.bash-completions

append_path $HOME/.scripts
append_path $HOME/all/bin
prepend_path $HOME/$(uname -m)/$(uname -s)/bin
read_file $HOME/.bash-env
test -z "$HISTFILE" && HISTFILE=$HOME/.bash-history-$$
export HISTFILE
if ! test -s "$HISTFILE"; then
	{
	printf '# %s: Shell %d begins' "$(date +%s)" "$$"
	if test "$PPID" -gt 0 2> /dev/null; then
		printf ', child of %s' "$(ps -o pid=,comm= $PPID)"
	fi
	printf '\n'
	} >> $HISTFILE
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
	return $_status
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
trap '. $HOME/.bashrc' SIGWINCH

PROMPT_COMMAND='after_cmd'
