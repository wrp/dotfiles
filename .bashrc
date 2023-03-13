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

# test -x /usr/bin/lesspipe && eval "$(SHELL=/bin/sh lesspipe)"

__RED=$(tput setaf 1)
__GREEN=$(tput setaf 2)
__YELLOW=$(tput setaf 3)
__MAGENTA=$(tput setaf 5)

unset PS1
read_file() { local f; for f; do if test -f "$f"; then . "$f"; fi; done; }
read_file $HOME/.bashd/*
read_file $HOME/.bash-functions $HOME/.bash-interactive-functions $HOME/.bash-completions
read_file $HOME/.bash-env $HOME/.bash-localenv

if test -z "$PS1"; then
	if test -n "$__RED" && test -n "$__GREEN"; then
		PS1+='\[$( # Colorize based on previous command status
			{ test $? -ne 0 && printf "%s" "$__RED" || printf "%s" "$__GREEN"; }
		)\]'
	fi
	if test "$(tput cols)" -gt 80; then
		PS1+="${PS1_PREFIX}"
		PS1+='\D{%T}'  # %T is passed to strftime for time
		PS1+='\[$__MAGENTA\]'
		PS1+='$( # project
			echo "${PROJECT:+(}${PROJECT%-[0-9]*}${PROJECT:+)}";
		)'
		PS1+='$( # directory and git branch
			if test "${COLUMNS:-0}" -gt 140; then printf "[%s%s%s]" \
				"${PS1_LEADER:+$PS1_LEADER:}" \
				"$(pwd 2> /dev/null | sed -E -e "s@^$HOME@~@" \
					-e "s@([^/]{1})[^/]*/@\1/@g" )" \
				"$( git rev-parse --abbrev-ref HEAD 2> /dev/null \
					| sed -E -e "s/^/@/" -e "s@^:heads/@:@" )"
			else printf :
			fi | tr \  .
		)'
	fi
	PS1+="$( printf "%05d" "$$" )\[$__GREEN\]\$ "
fi

complete -r
make_hist_file() {
	if ! test -s "$1"; then
		{
		printf '# %s: Shell %d begins' "$(date +%s)" "$$"
		if test "$PPID" -gt 0 2> /dev/null; then
			printf ', child of %s' "$(ps -o pid=,comm= $PPID)"
		fi
		printf '\n'
		} >> $1
	fi
	export HISTFILE=$1
}
make_hist_file $HOME/.bash-history-dir/.bash-history-$$
export HISTCONTROL=ignoredups
export IGNOREEOF=4
set -o vi
set -o physical # make pwd do the right thing w.r.t. symbolic links
shopt -s histappend
shopt -s cmdhist
shopt -s checkwinsize
shopt -s histverify
shopt -s cdable_vars 2> /dev/null
shopt -s direxpand 2> /dev/null # prevent tab expand from expanding $D to \$D
# set +H      # disable history expansion

debug_trap() {
	# Runs before a command in an interactive shell
	if test "$IFS" != $' \t\n'; then
		echo "WARNING: IFS contains unexpected characters"
	fi

	history -a || echo 'WARNING: history -a failed'

	# Emit a warning if the history file is not updating
	# When a shell starts up, the debug trap is being called multiple times
	# before any commands have been executed.  In that case, fc emits no ouptut
	# and we do not want to emit a warning about the HISTFILE in that situation.
	if ! test -f "$HISTFILE" || ! {
		local last  # last is the first word of the most recent command
		last=$(fc -l -1 2> /dev/null | awk '{print $2; exit}')
		# Check the last command to ensure that the HISTFILE is updating.
		# Last command may be multi-line, hence the tac.
		test -z "$last" || tac "$HISTFILE" |
			awk '/^#/ && a++ > 2 {exit}
			$1 == "rh" || $1 == last {b++} END{ exit !b }' last="$last";
	} 2> /dev/null
	then
		echo 'WARNING: HISTFILE is not updating!!'
	fi
	if test -z "$TMUX" && test -z "$NO_TMUX_OK"; then
		echo 'WARNING: not running in TMUX! (set NO_TMUX_OK to suppress warning)'
	fi
} >&2

after_cmd() {
	# Run after a command, and before a prompt is displayed
	local _status=$?
	report_cmd_status $HISTFILE $_status >> $HOME/.bash-history
	window-title "$__pane_title"
	unset __pane_title
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
				"'"${DOCKER:+ on }$DOCKER"'",
				$ENV{STATUS} > 0 ? "FAILED" : "ok",
				@ge;
			print;  # Since about to skip auto print with -p
			exit 0; # Exit so we only process most recent command
		}
	' | tac | perl -ne '
		$ts = $_ if $. == 1;
		if( $. == 2 )  {
			exit 0 if /^history/;     # ignore history
			exit 0 if /^[a-z]{1,2}$/;   # 2 letter cmds w/no args
			foreach $cmd (
					"cal", "cat", "cd", "date", "echo", "exec bash",
					"head", "less", "ls", "more", "pwd", "tail", "man"
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

PROMPT_COMMAND=after_cmd
read_file $HOME/.bash-local
