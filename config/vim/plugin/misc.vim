" Just like windo, but restore the current window when done.
function! WinDo(command)
  let currwin=winnr()
  execute 'windo ' . a:command
  execute currwin . 'wincmd w'
endfunction
com! -nargs=+ -complete=command Windo call WinDo(<q-args>)

function! Get_option(name, default)
	return trim(system('guess-vim-setting ' . a:name . ' ' .
	\ expand('%:p') . ' ' . expand(&filetype) . ' || echo ' . a:default))
endfunction

function! Guess_expandtab()
	if Get_option('expandtab', 'noexpandtab') == 'expandtab'
		set expandtab
	else
		set noexpandtab
	endif
endfunction

function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

function! SynGroup()
    let l:s = synID(line('.'), col('.'), 1)
    echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun
