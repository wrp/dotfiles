
if ! empty( $MAX_GIT_SUMMARY )
	execute 'syn match gitcommitSummary "^.\{0,' . $MAX_GIT_SUMMARY . '\}" contained containedin=gitcommitFirstLine nextgroup=gitcommitOverflow contains=@Spell'
endif
if ! empty( $MAX_GIT_WIDTH )
	execute 'set textwidth=' . $MAX_GIT_WIDTH
endif
