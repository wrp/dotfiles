
if &filetype ==# 'c'
	setlocal shiftwidth=8
	setlocal tabstop=8
	setlocal noexpandtab
endif
set iskeyword=@,48-57,_,192-255
set textwidth=80
syntax keyword   Type   pid_t
"set colorcolumn+=+1,+2,+3
