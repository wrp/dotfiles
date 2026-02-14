

hi link LeadingTabs Folded
augroup LeadingTabs
	autocmd!
	autocmd Syntax * syn match LeadingTabs "^\t\+" containedin=ALL
augroup END

function! ToggleLeadingTabs()
	if get(g:, 'leading_tabs_on', 1)
		hi link LeadingTabs NONE
		let g:leading_tabs_on = 0
	else
		hi link LeadingTabs Folded
		let g:leading_tabs_on = 1
	endif
endfunction
nnoremap <silent> gt :call ToggleLeadingTabs()<CR>
