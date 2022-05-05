
" map [[ :call search('^ \{0,'.(indent(".")-1).'}\S\|^ \{'.(indent(".")+1).',}\S')

" Jump to the next or previous line that has the same level or a lower
" level of indentation than the current line.
"
" exclusive (bool): true: Motion is exclusive
" false: Motion is inclusive
" fwd (bool): true: Go to next line
" false: Go to previous line
" lowerlevel (bool): true: Go to line with lower indentation level
" false: Go to line with the same indentation level
" skipblanks (bool): true: Skip blank lines
" false: Don't skip blank lines

set fdm=indent
set foldlevel=0
"set sw=2
"set ts=2
"set et
setlocal shiftwidth=4
setlocal tabstop=4
setlocal expandtab
set expandtab
hi IndentGuidesOdd  guibg=red   ctermbg=7
hi IndentGuidesEven guibg=green ctermbg=6

function! NextIndent(exclusive, fwd, lowerlevel, skipblanks)
  let line = line('.')
  let column = col('.')
  let lastline = line('$')
  let indent = indent(line)
  let stepvalue = a:fwd ? 1 : -1
  while (line > 0 && line <= lastline)
    let line = line + stepvalue
    if ( ! a:lowerlevel && indent(line) == indent ||
          \ a:lowerlevel && indent(line) < indent)
      if (! a:skipblanks || strlen(getline(line)) > 0)
        if (a:exclusive)
          let line = line - stepvalue
        endif
        exe line
        exe "normal " column . "|"
        return
      endif
    endif
  endwhile
endfunction

" Moving back and forth between lines of same or lower indentation.
"nnoremap <silent> [l :call NextIndent(0, 0, 0, 1)<CR>
"nnoremap <silent> ]l :call NextIndent(0, 1, 0, 1)<CR>
noremap <silent> [[ :call NextIndent(0, 0, 1, 1)<CR>
noremap <silent> ]] :call NextIndent(0, 1, 1, 1)<CR>
"vnoremap <silent> [l <Esc>:call NextIndent(0, 0, 0, 1)<CR>m'gv''
"vnoremap <silent> ]l <Esc>:call NextIndent(0, 1, 0, 1)<CR>m'gv''
"vnoremap <silent> [[ <Esc>:call NextIndent(0, 0, 1, 1)<CR>m'gv''
"vnoremap <silent> ]] <Esc>:call NextIndent(0, 1, 1, 1)<CR>m'gv''
"onoremap <silent> [l :call NextIndent(0, 0, 0, 1)<CR>
"onoremap <silent> ]l :call NextIndent(0, 1, 0, 1)<CR>
"onoremap <silent> [[ :call NextIndent(1, 0, 1, 1)<CR>
"onoremap <silent> ]] :call NextIndent(1, 1, 1, 1)<CR>
"
hi IndentGuidesOdd  guibg=red ctermbg=7
hi IndentGuidesEven guibg=green "ctermbg=6
