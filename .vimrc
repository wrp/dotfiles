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

function! ClearWhite()
    " A bit hacky: if you :let keep_white=1 before you
    " do any writes, you can keep trailing whitespace
    if !exists("g:keep_white")
        let l:save_pos = getcurpos()
        execute '%s/\s\+$//e'
        call cursor(l:save_pos[1:])
    endif
endfunction
autocmd BufWritePre * call ClearWhite()


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
set scrolloff=5
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

call plug#begin('~/.vim/plugged')
" Declare the list of plugins.
" (Get plugin manager with:
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"
Plug 'junegunn/vim-easy-align'
" See https://github.com/junegunn/vim-easy-align
call plug#end()


" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" " Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" Grrr.  I occasionally get ft set to things that change my formatoptions
" eg, if vim sets ft=conf, it add 'r' and 'o'.  Get rid of them!
autocmd BufEnter * set formatoptions-=ro
autocmd BufEnter * set indentexpr=

" vim: fen:sw=4 fdm=indent fdl=1
