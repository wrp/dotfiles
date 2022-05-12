" Functions to send text from vim to a tmux pane.  This
" maps <C-c><C-c> to a function that send either the current
" paragraph or the currently selected visual text to a pane.
" Target pane can be found by examining TMUX_PANE in the target.

" Modified from http://s3.amazonaws.com/mps/slime.vim
" See:
"   https://technotales.wordpress.com/2007/10/03/like-slime-for-vim/
"   https://github.com/jpalardy/vim-slime

function Send_to_Pane(text)
  if !exists("g:tmux_target")
    call Tmux_Vars()
  end

  echo system("tmux send-keys -t " . g:tmux_target . " '" . substitute(a:text, "'", "'\\\\''", 'g') . "'")
endfunction

function Tmux_Pane_Names(A,L,P)
  return system("tmux list-panes -a | awk '/active/ {printf \"%s:%s\n\", $1, $2}' FS=:")
endfunction

function Tmux_Vars()
  if !exists("g:tmux_target")
    let g:tmux_target = "%1"
  end

  let g:tmux_target = input("session:window.pane> ", "%1", "custom,Tmux_Pane_Names")
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

vmap <C-c><C-c> "ry :call Send_to_Pane(@r)<CR>
nmap <C-c><C-c> vip<C-c><C-c>

nmap <C-c>v :call Tmux_Vars()<CR>
