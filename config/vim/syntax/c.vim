
if &filetype ==# 'c'
	setlocal shiftwidth=8
	setlocal tabstop=8
	setlocal noexpandtab
endif
set iskeyword=@,48-57,_,192-255
set textwidth=80
set colorcolumn=80
syntax keyword   Type   pid_t
