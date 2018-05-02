
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

func tmux#run_in_pane(target_title, prg, ...)
	let args = a:0 > 0 ? a:000 : get(b:, 'tmux_args', [])
	let args = map(copy(args), {i, val -> shellescape(val)})
	let buffer = shellescape(expand('%:p'))
	let cmd = printf("'clear' Enter \"%s %s %s\" Enter", a:prg, buffer, join(args, ' '))
	if s:tmux('display -p "#{window_zoomed_flag}"') == 1
		call s:tmux('resizep -Z')
	end
	if s:tmux('display -p "#{window_panes}"') == 1
		" automatically setup a new pane
		call s:tmux('splitw -v -p 25 -c "#{pane_current_path}"')
		call s:tmux(printf('selectp -T "%s"', a:target_title))
		call s:tmux('selectp -t :.! ')
	end
	let panes = s:tmux('lsp -F "#{pane_id}:#{pane_title}"', 1)
	for [id, title] in map(panes, {i, line -> split(line, ':')})
		if title == a:target_title
			return s:tmux(printf('send -t %s %s', id, cmd))
		end
	endfo
	call s:err(printf("Please run \"selectp -T '%s'\" on the target pane.", a:target_title))
endf
