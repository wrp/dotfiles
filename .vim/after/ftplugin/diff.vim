" Fold based on diff header
setlocal foldmethod=expr
setlocal foldexpr=DiffFold(v:lnum)
" setlocal foldlevel=1

function! DiffFold(lnum)
    let line = getline(a:lnum)
    if line =~ '^diff'
        return '>1'
    elseif line =~ '^---'
        for i in range(1,3)
            if getline(a:lnum - i) =~ '^diff'
                return '='
            endif
        endfor
        return '>1'
    elseif line =~ '^@@'
        return '>2'
    elseif line =~ '^$'
        return 0
    else
        return '='
    endif
endfunction

function! MyFoldText()
    let line = getline(v:foldstart)
    let next_line = getline(v:foldstart + 1)
    let folded_line_count = v:foldend - v:foldstart + 1

    let fold_info = line
    if line =~ '^diff'
        let fold_info = split(line)[2][2:]
        if next_line =~ "new file"
            let fold_info = "New file: " . fold_info
        endif
    elseif line =~ '^---'
        let w = split(line)
        if w[1] ==# "/dev/null"
            let fold_info = "New file: " . split(next_line)[1]
        else
            let fold_info = split(line)[1]
        endif
    endif

    return printf("%4d %s: %s",
        \ folded_line_count,
        \ repeat(">>>>", foldlevel(v:foldstart)),
        \ fold_info
    \)
endfunction
set foldtext=MyFoldText()
