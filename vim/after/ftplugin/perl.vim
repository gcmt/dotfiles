

if exists('$TMUX')
	let b:tmux = {'prg': 'perl'}
	nnoremap <silent> <buffer> <leader>r :call tmux#run_buffer()<cr>
	nnoremap <silent> <buffer> <leader>z :call tmux#exec('resizep -Z')<cr>
else
	nnoremap <silent> <buffer> <leader>r :!perl %<cr>
end
