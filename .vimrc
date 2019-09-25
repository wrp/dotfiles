autocmd BufWritePre * :%s/\s\+$//e
noremap v V
noremap V v
noremap ; :
noremap , ;
noremap ' `
noremap ` '
noremap gw :Windo set wrap!

" Just like windo, but restore the current window when done.
function! WinDo(command)
  let currwin=winnr()
  execute 'windo ' . a:command
  execute currwin . 'wincmd w'
endfunction
com! -nargs=+ -complete=command Windo call WinDo(<q-args>)

" inoremap jk <esc>
let loaded_matchparen=1
set foldlevelstart=1
set iskeyword=@,48-57,_,192-255,-
set modelines=10
set modeline
set ai
set hlsearch
set listchars=extends:%,precedes:%,eol:$,tab:>-,trail:$
set matchpairs+=<:>
set nowrap
" set sidescroll=1
set nowrapscan
" set smartindent
" set cindent
set tildeop
set t_ti= t_te=  " Disable clear screen on exit
set novisualbell
set noerrorbells
" set virtualedit=all
set wildmenu
set wildmode=longest,list,full
"set textwidth=80
"set colorcolumn+=+1
highlight ColorColumn ctermbg=green
highlight Folded ctermbg=black
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
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
	\ call system("test -z \"$NORENAMEVIM\" && rename-tmux-window " .
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

set swapfile
set directory^=~/.vim/swap//
set writebackup
set backupcopy=auto
if has("patch-8.1.0251")
        set backupdir^=~/.vim/backup//
end
set undofile
set undodir^=~/.vim/undo//

" vim: fen:sw=4 fdm=indent fdl=1
