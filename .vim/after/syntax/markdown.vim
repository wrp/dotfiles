
" Stop stray * from opening an endless emphasis region
silent! syn clear markdownItalic markdownItalicDelimiter markdownBold markdownBoldDelimiter

" Redefine: require a closing * later on the same line and non-space content inside
syn match markdownItalic '\%(\*\)\@<!\*\%(\S.\{-}\S\)\*\@=' contains=NONE display
syn match markdownBold   '\%(\*\)\@<!\*\*\%(\S.\{-}\S\)\*\*\@=' contains=NONE display

" Link (or tone down) the highlight to something you prefer
hi def link markdownItalic   Italic
hi def link markdownBold     Bold
