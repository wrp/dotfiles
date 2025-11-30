vim9script


var max_summary = system('printf "${MAX_GIT_SUMMARY:-$(' ..
	\ 'git config commit.max-summary-width)}"')

var max_width = system('printf "${MAX_GIT_WIDTH:-$(' ..
	\ 'git config commit.max-message-width)}"')


if len(max_summary) > 0
	execute 'syn match gitcommitSummary "^.\{0,' .. max_summary ..
	\ '\}" contained containedin=gitcommitFirstLine ' ..
	\ 'nextgroup=gitcommitOverflow contains=@Spell'
endif

if len(max_width) > 0
	execute 'set colorcolumn=' .. max_width
endif
