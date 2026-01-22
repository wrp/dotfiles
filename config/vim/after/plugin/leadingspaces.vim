

syn match LeadingSpaceError "^ \+"
hi link LeadingSpaceError Folded
augroup LeadingSpaces
	autocmd!
	autocmd Syntax * syn match LeadingSpaceError "^ \+"
augroup END
