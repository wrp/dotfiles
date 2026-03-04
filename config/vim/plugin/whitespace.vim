" Use 'git config vi.whitespace keep' or :let b:keep_white=1 to retain
" trailing whitepsace

function! CheckGitConfig()
	let l:old_value = get(b:, 'keep_white', 2)
	let l:new_value = system('git -C ' . shellescape(expand('%:p:h')) . ' config --get vi.whitespace 2>/dev/null') =~? 'keep'

	if l:new_value
		let b:keep_white = 1
	elseif exists('b:keep_white')
		let b:keep_white = 0
	endif
	if l:old_value != 2 && l:new_value != l:old_value
		echohl WarningMsg
		echom l:new_value ? "Keeping trailing whitespace due to vi.whitespace git config" : "Resuming auto-trim of trailing whitespace"
		echohl None
	endif
endfunction

function! CheckTrailingWhitespace()
	" Only check once per buffer
	if get(b:, 'checked_whitespace', 0)
		return
	endif
	let b:checked_whitespace = 1

	" Skip if keep_white already set (by git config or local .vimrc or user)
	if get(b:, 'keep_white', 0)
		return
	endif

	" Search for trailing whitespace
	let l:save_pos = getcurpos()
	let l:has_trailing = search('\s\+$', 'nw')
	call setpos('.', l:save_pos)

	"TODO: do not prompt if in readonly mode; assume no trim
	if l:has_trailing
		echom "'git config vi.whitespace keep' to prevent auto-trim."
		let l:choice = confirm("File has trailing whitespace. Trim on write?", "&Yes\n&No", 1)
		if l:choice == 2
			let b:keep_white = 1
			echohl WarningMsg
			echom "Preserving trailing whitespace for this buffer"
			echohl None
		endif
	endif
endfunction

function! ClearWhite()
	" A bit hacky: if you :let b:keep_white=1 before you
	" do any writes, you can keep trailing whitespace
	if !exists("b:keep_white") || b:keep_white != 1
		let l:save_pos = getcurpos()
		execute '%s/\s\+$//e'
		call cursor(l:save_pos[1:])
		call histdel("search", -1)
	endif
endfunction

highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

autocmd BufWritePre * call ClearWhite()
autocmd BufReadPost * call CheckGitConfig() | call CheckTrailingWhitespace()
