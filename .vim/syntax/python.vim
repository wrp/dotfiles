setlocal shiftwidth=4
setlocal tabstop=4
setlocal expandtab
"set foldmethod=expr foldexpr=getline(v:lnum)=~'^\\s*'.&commentstring[0]
set foldmethod=indent
set foldlevelstart=0

let g:keep_white=0

syn region pythonString
      \ start=+[uU]\=\z('''\|"""\)+ end="\z1" keepend transparent fold
syn region pythonRawString
      \ start=+[uU]\=[rR]\z('''\|"""\)+ end="\z1" keepend transparent fold
