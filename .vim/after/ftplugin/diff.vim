" Fold based on diff header
setlocal foldmethod=expr
setlocal foldexpr=DiffFold(v:lnum)
" setlocal foldlevel=1

function! DiffFold(lnum)
    let line = getline(a:lnum)
    let pline = getline(a:lnum - 2)
    if line =~ '^diff'
        return '>1'
    elseif line =~ '^---' && pline !~ '^diff'
        return '>1'
    elseif line =~ '^@@'
        return '>2'
    else
        return '='
    endif
endfunction

function! MyFoldText()
    let line = getline(v:foldstart)
    let folded_line_count = v:foldend - v:foldstart + 1

    let fold_info = line
    if line =~ '^diff'
        let word = split(line)
        let fold_info = word[2][2:]
    endif

    return printf("%4s%4d: %s", repeat("-", foldlevel(v:foldstart)),
        \ folded_line_count, fold_info)
endfunction
set foldtext=MyFoldText()
