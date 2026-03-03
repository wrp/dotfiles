" local syntax file - set colors on a per-machine basis:
" Vim color file
" Maintainer:	William Pursell
" Last Change:	2025 July 29

hi clear
set background=dark
if exists("syntax_on")
        syntax reset
endif
let g:colors_name = "wrp"

" 5 - lavender
" 6 - cyan

highlight Comment    ctermfg=8
highlight Constant   ctermfg=14            cterm=none
highlight Identifier ctermfg=6
highlight Statement  ctermfg=3             cterm=bold
highlight PreProc    ctermfg=5
highlight Type       ctermfg=2
highlight Special    ctermfg=12
highlight Error                 ctermbg=9
highlight Todo       ctermfg=4  ctermbg=3
highlight Directory  ctermfg=2
highlight StatusLine ctermfg=lightyellow ctermbg=black cterm=none
" highlight Normal
highlight Search                ctermbg=LightBlue

" To see colors, try :highlight and :runtime syntax/colortest.vim
" cut-n-pasteable shell snippet to sample colors:
"" trap : DEBUG; for fg in $(seq 0 15); do $( : \
"" );  for i in $(seq 0 15); do $( : \
"" )     tput setaf $fg; tput setab $i; printf " %2d " $i; $( : \
"" );  done; tput sgr0; echo ; done
