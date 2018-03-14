
func! python#utils#tmux_run(...)
	let args = a:0 > 0 ? a:000 : get(b:, 'args', [])
	let args = map(copy(args), 'shellescape(v:val)')
	let buffer = shellescape(expand('%:p'))
	let cmd = printf("'clear' Enter \"python %s %s\" Enter", buffer, join(args, ' '))
	call system("tmux send -t :.+ " . cmd)
endf
