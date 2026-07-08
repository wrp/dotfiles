let s:timer_id = 0

function! s:Clear(timer_id)
	setlocal nocursorline
	let s:timer_id = 0
endfunction

function! s:Toggle()
	if s:timer_id
		call timer_stop(s:timer_id)
		call s:Clear(0)
		return
	endif
	highlight CursorLine cterm=reverse gui=reverse
	setlocal cursorline
	let s:timer_id = timer_start(1000, function('s:Clear'))
endfunction

nnoremap <silent> <Space> :call <SID>Toggle()<CR>
