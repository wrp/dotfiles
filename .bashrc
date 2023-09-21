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
case "$-" in *i*) : ;; *) return 0 ;; esac

unalias -a   # Remove all existing aliases
complete -r  # Remove all existing completion specs
unset PS1    # Set PS1 from ~.bashd/PS1
read_file() { local f; for f; do if test -f "$f"; then . "$f"; fi; done; }
read_file $HOME/.bashd/*
read_file $HOME/.bash-functions $HOME/.bash-interactive-functions $HOME/.bash-completions
read_file $HOME/.bash-env $HOME/.bash-localenv

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
				POSIX::strftime("%a %b %d %H:%M:%S GMT", gmtime $1),
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
