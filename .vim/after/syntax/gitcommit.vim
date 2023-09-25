execute 'syn match gitcommitSummary "^.\{0,' . $MAX_GIT_SUMMARY . '\}" contained containedin=gitcommitFirstLine nextgroup=gitcommitOverflow contains=@Spell'
