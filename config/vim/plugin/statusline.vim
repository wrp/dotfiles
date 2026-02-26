function! TruncatedStatus()
	return virtcol('$') > winwidth(0) ?  &wrap ? "<--" : "[TRUNCATED]" : ""
endfunction

" m:modified, %r:read-only, %f:path, %y:filetype, %=:horizontal break
set statusline=%m%r%f\ %y%=%{TruncatedStatus()}\ (%B)\ line:%l/%L(%p%%)\ column:%c%V\ buffer:%n
set laststatus=2   " Always show status line
