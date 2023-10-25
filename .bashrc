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
read_file $HOME/.bash-env

make_hist_file $HOME/.bash-history-dir/.bash-history-$$
set -o vi
set -o physical # make pwd do the right thing w.r.t. symbolic links
shopt -s histappend
shopt -s cmdhist
shopt -s checkwinsize
shopt -s histverify
shopt -s cdable_vars 2> /dev/null
shopt -s direxpand 2> /dev/null # prevent tab expand from expanding $D to \$D
# set +H      # disable history expansion

trap archive 0
trap debug_trap DEBUG
trap '. $HOME/.bashrc' SIGUSR1
trap '. $HOME/.bashrc' SIGWINCH

PROMPT_COMMAND=after_cmd
read_file $HOME/.bash-local

if test -z "${TMUX}"; then
	echo "WARNING: not running in TMUX!"
fi
return 0
