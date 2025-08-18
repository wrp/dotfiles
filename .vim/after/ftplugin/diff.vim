" Fold based on diff header
setlocal foldmethod=expr
setlocal foldexpr=DiffFold(v:lnum)
" setlocal foldlevel=1

function! DiffFold(lnum)
    let line = getline(a:lnum)
    if line =~ '^diff'
        return 0
    elseif line =~ '^@@'
        return 1
    else
        return 2
    endif
endfunction
