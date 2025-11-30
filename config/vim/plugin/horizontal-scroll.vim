
nnoremap <silent> zh :call HorizontalScrollMode('h')<CR>
nnoremap <silent> zl :call HorizontalScrollMode('l')<CR>
nnoremap <silent> zH :call HorizontalScrollMode('H')<CR>
nnoremap <silent> zL :call HorizontalScrollMode('L')<CR>

function! HorizontalScrollMode( call_char )
	if &wrap
		return
	endif

	echohl Title
	let typed_char = a:call_char
	while index( [ 'h', 'l', 'H', 'L' ], typed_char ) != -1
		execute 'normal! z'.typed_char
		redraws
		echon '-- Horizontal scrolling mode (h/l/H/L)'
		let typed_char = nr2char(getchar())
	endwhile
	echohl None | echo '' | redraws
endfunction
