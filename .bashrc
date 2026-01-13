# Startup file for interactive non-login shells

# This is getting read for non-interactive shells via ssh
# From bash(1):
#    Bash  attempts  to  determine  when it is being run with its
#    standard input connected to a network connection, as when executed
#    by the remote shell daemon, usually rshd, or the secure shell
#    daemon sshd.  If bash determines it is being run in this fashion,
#    it reads  and executes commands from ~/.bashrc, if that file
#    exists and is readable.  It will not do this if invoked as sh.
#    The --norc option may be used to inhibit this behavior, and the
#    --rcfile option may be used to force another file to be read, but
#    neither rshd nor sshd  generally  invoke  the  shell  with those
#    options or allow them to be specified.
#
# But this should only be used in interactive shells, so make it explicit.
case "$-" in *i*) : ;; *) return 0 ;; esac

if test -n "$V"; then
	perl -MPOSIX=strftime -E 'say strftime("%FT%T%z", localtime) .
		": Re-reading .bashrc"'
fi

unalias -a   # Remove all existing aliases
complete -r  # Remove all existing completion specs

unset_all_functions() {
	while read func; do
		unset -f "$func"
	done <<- EOF
	$(compgen -A function)
	EOF
}

unset_all_functions
unset PS1    # Set PS1 from ~.bashd/PS1
read_file() { local f; for f; do if test -f "$f"; then . "$f"; fi; done; }
read_file "$HOME"/.bashd/colors
read_file "$HOME"/.bash-functions
read_file "$HOME"/.bash-env
read_file "$HOME"/.bash-interactive-functions
read_file "$HOME"/.bash-completions
read_file "$HOME"/.bashd/*
read_file "$HOME"/.bash-local

write_hist_file
set -o vi
set -o physical # make pwd do the right thing w.r.t. symbolic links
shopt -s histappend
shopt -s cmdhist
shopt -s checkwinsize
shopt -s histverify
shopt -s cdable_vars 2> /dev/null
shopt -s direxpand 2> /dev/null # prevent tab expand from expanding $D to \$D
# set +H      # disable history expansion

trap archive-bash-history 0
trap debug_trap DEBUG # Run before a command in an interactive shell
trap 'V=1 SKIP_SECRETS=1 . "$HOME"/.bashrc' SIGUSR1
trap '. "$HOME"/.bashd/PS1; window-title' SIGWINCH
check_directory_existence $HOME/.config git vim
check_directory_existence $HOME/.run vim/{swap,backup,undo}
PROMPT_COMMAND=after_cmd # Run after a command, before a prompt is displayed
window-title

if test "${BASH_VERSINFO[0]}" -lt 5; then
	if test "$(bash -c 'echo $BASH_VERSINFO')" -ge 5; then
		exec bash
	fi
	warn "You are using bash version $BASH_VERSION.  It is obsolete!"
fi
return 0
