" See :help fold-foldtext for details
set foldtext=MyFoldText()
function! MyFoldText()
    let prefix = printf("%3d: ", v:foldend - v:foldstart + 1)
    for i in range(v:foldstart, v:foldend)
    let line = getline(i)
    if match(line, '^[ %#/\{}*-]*$') == -1
       return prefix . line
    endif
    endfor
    return prefix . "Trivial fold"
endfunction
