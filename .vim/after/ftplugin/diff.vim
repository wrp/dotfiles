" Fold based on diff header
setlocal foldmethod=expr
setlocal foldexpr=DiffFold(v:lnum)
" setlocal foldlevel=1

function! DiffFold(lnum)
    let line = getline(a:lnum)
    if line =~ '^diff'
        return '>1'
    elseif line =~ '^---'
        return '>2'
    elseif line =~ '^@@'
        return '>3'
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

    " Add padding to fill the line if needed, or adjust as per preference
    "let fill_char = '-'
    "let max_width = winwidth(0) - v:foldlevel * &foldcolumn - 2 " Adjust for window width, fold level, and foldcolumn
    "let padded_fold_info = strpart(fold_info, 0, max_width)
    return printf("%d: %s", folded_line_count, fold_info)
endfunction
set foldtext=MyFoldText()
