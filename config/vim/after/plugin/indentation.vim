hi IndentGrey ctermbg=8
hi IndentRed ctermbg=red

augroup LeadingWhitespace
	autocmd!
	autocmd Syntax * syn match LeadingTabs "^\t\+" containedin=ALL
	autocmd Syntax * syn match LeadingSpaces "^ \+" containedin=ALL
augroup END

let g:indent_highlight_state = 0

function! CycleIndentHighlight()
	let g:indent_highlight_state = (g:indent_highlight_state + 1) % 3
	if g:indent_highlight_state == 1
		hi link LeadingTabs IndentGrey
		hi link LeadingSpaces IndentRed
	elseif g:indent_highlight_state == 2
		hi link LeadingTabs IndentRed
		hi link LeadingSpaces IndentGrey
	else
		hi link LeadingTabs NONE
		hi link LeadingSpaces NONE
	endif
endfunction
nnoremap <silent> gt :call CycleIndentHighlight()<CR>
