
func s:err(msg)
	echohl ErrorMsg | echo a:msg | echohl None
endf

func s:tmux(cmd, ...)
	let fn = a:0 > 0 && a:1 ? 'systemlist' : 'system'
	return call(fn, ['tmux ' . a:cmd])
endf

func tmux#run(cmd)
	return s:tmux(a:cmd)
endf

" tmux#run_in_pane({pane_title:string}[, {prg:string}[, {args:list}]]) -> 0
" Run the current file in a pane titles {pane_title}. If it does not exist, it
" is created first.
" {prg} is the executable program used to execute the current buffer.
" {args} is a list of arguments passed to the executed file.
" Variables b:tmux_prg and b:tmux_args take precedence over these tow parameters.
func tmux#run_in_pane(pane_title, ...)
	let prg = get(b:, 'tmux_prg', get(a:000, 0, ''))
	let args = get(b:, 'tmux_args', get(a:000, 1, []))
	let file = shellescape(expand('%:p'))
	let args = map(copy(args), {i, val -> shellescape(val)})
	let cmd = printf("'clear' Enter \"%s %s %s\" Enter", prg, file, join(args, ' '))
	if s:tmux('display -p "#{window_zoomed_flag}"') == 1
		call s:tmux('resizep -Z')
	end
	if s:tmux('display -p "#{window_panes}"') == 1
		" automatically setup a new pane
		call s:tmux('splitw -v -p 25 -c "#{pane_current_path}"')
		call s:tmux(printf('selectp -T "%s"', a:pane_title))
		call s:tmux('selectp -t :.! ')
	end
	let panes = s:tmux('lsp -F "#{pane_id}:#{pane_title}"', 1)
	for [id, title] in map(panes, {i, line -> split(line, ':')})
		if title == a:pane_title
			call s:tmux(printf('send -t %s %s', id, cmd))
			return
		end
	endfo
	call s:err(printf("Please run \"selectp -T '%s'\" on the target pane.", a:pane_title))
endf
