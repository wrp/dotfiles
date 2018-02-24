autocmd BufWritePre !*.test :%s/\s\+$//e
nore v V
nore V v
nore ; :
nore , ;
inoremap jk <esc>
let loaded_matchparen=1
set iskeyword=@,48-57,_,192-255,-
set ai
set hlsearch
set listchars=extends:%,precedes:%,eol:$,tab:>-,trail:$
set matchpairs+=<:>
set nowrap
set nowrapscan
" set smartindent
" set cindent
set tildeop
set t_ti= t_te=  " Disable clear screen on exit
set wildmenu
set wildmode=longest,list,full
"set textwidth=80
"set colorcolumn+=+1
highlight ColorColumn ctermbg=green
highlight Folded ctermbg=black
syntax on

" Attempt to deal with a brain-dead coding style that
" does not put { in the first column
" map [[ ?{<CR>w99[{<esc>:nohlsearch
" map ][ /}<CR>b99]}<esc>:nohlsearch
" map ]] j0[[%/{<CR><esc>:nohlsearch
" map [] k$][%?}<CR><esc>:nohlsearch
"map [[ ][%
"map ]] ][][%

autocmd BufEnter,BufReadPost,FileReadPost,BufNewFile *
	\ call system("test -z \"$NORENAMEVIM\" && rename-tmux-pane " .
	\ expand("%"))

if &diff
	highlight DiffAdd ctermbg=5
endif

au BufNewFile,BufRead .bash-history setlocal path+=$HOME/.bash-history-dir

set includeexpr=substitute(v:fname,'^//','','')

filetype plugin on

highlight Comment ctermfg=darkcyan
set cinkeys="0{,0},0),!^F,o,O,e"

set formatoptions=cq
set comments=
