" see :help filetype
" synopsis:
" executing ':filetype on' causes vim to read $VIMRUNTIME/filetype.vim
" which sets up autobuf read, etc.  If the file type cannot be determined,
" then this script gets read to attempt the determine the filetype.
"

if did_filetype()       " filetype already set..
  finish                " ..don't do these checks
endif
if getline(1) =~ '^#!.*\<python\>'
  setfiletype python
endif
