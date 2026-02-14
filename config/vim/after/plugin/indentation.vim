

hi link LeadingTabs Folded
augroup LeadingTabs
	autocmd!
	autocmd Syntax * syn match LeadingTabs "^\t\+" containedin=ALL
augroup END
