
if exists('$TMUX')
	nnoremap <silent> <buffer> <leader>r :call tmux#run_in_pane('tmux-run', 'perl')<cr>
	nnoremap <silent> <buffer> <leader>z :call tmux#run('resizep -Z')<cr>
else
	nnoremap <silent> <buffer> <leader>r :!perl %<cr>
end
