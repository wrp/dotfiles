

syn match LeadingSpaceError "^ \+" containedin=ALL
hi link LeadingSpaceError Folded
augroup LeadingSpaces
	autocmd!
	autocmd Syntax * syn match LeadingSpaceError "^ \+" containedin=ALL
augroup END
