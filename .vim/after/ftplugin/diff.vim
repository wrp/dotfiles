" Fold based on diff header
setlocal foldmethod=expr
setlocal foldexpr=DiffFold(v:lnum)
setlocal foldlevel=1

function! DiffFold(lnum)
    let line = getline(a:lnum)
    if line =~ '^diff'
        return 1
    elseif line =~ '^@@'
        return 2
    else
        return 3
    endif
endfunction
