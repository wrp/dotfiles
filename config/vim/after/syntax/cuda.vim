

" This match is too aggressive
" syn match cudaType /\<cu[A-Z][A-Za-z0-9_]*\>/

syn keyword cudaType cuFloatComplex cuDoubleComplex cuComplex
hi def link cudaType Type
