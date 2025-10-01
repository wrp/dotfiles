
This is my dotfiles.  The "setup" script will create the appropriate
symbolic links for dotfiles in $HOME and will create some directories
in $HOME and $HOME/config.  There is a small effort made to avoid
overwriting existing files, but no extensive testing has been done
as this is primarily intended to be run to setup a new account.  If
not already set in the environment, you will be prompted for EMAIL
and UNAME, which will be used to set the default values in git
config and in bash startup files.  (We use UNAME to allow a difference
from NAME, which is probably follows some corporate policy and is
not actually your name.)
