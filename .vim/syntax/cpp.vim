setlocal shiftwidth=4
setlocal tabstop=4
setlocal expandtab
set foldlevelstart=0
set foldmethod=manual
" syn match comment "\v(^\s*//.*\n)+" fold
if line('$') >= 29
	1,29fold
endif
let &tabstop = str2nr(Get_option('tabstop', 8))
let &shiftwidth = str2nr(Get_option('shiftwidth', 8))
let g:keep_white = str2nr(Get_option('keep_white', 0))
