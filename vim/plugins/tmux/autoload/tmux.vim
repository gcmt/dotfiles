
func s:err(msg)
	echohl ErrorMsg | echo a:msg | echohl None
endf

" s:tmux({cmd:string}[, {list:number}]) -> string
" Execute the tmux command {cmd}.
" If {list} is given and it's true, the command output is returned as a list of
" lines.
func s:tmux(cmd, ...)
	let fn = a:0 > 0 && a:1 ? 'systemlist' : 'system'
	return call(fn, ['tmux ' . a:cmd])
endf

" tmux#exec({cmd:string}[, {list:number}]) -> 0
" Execute a tmux command.
func tmux#exec(cmd)
	return s:tmux(a:cmd)
endf

" tmux#run_buffer([{options:dict}]) -> 0
" Run the current buffer in a pane titled {options.pane}. If it does not exist, it
" is created first.
" When {options} is not given, the variable b:tmux is looked for.
func tmux#run_buffer(...)
	let defaults = {'prg': '', 'args': [], 'pane': 'vim-tmux', 'focus': 0}
	let opts = extend(defaults, a:0 > 0 ? a:1 : get(b:, 'tmux', {}), 'force')
	let file = shellescape(expand('%:p'))
	let args = map(copy(opts.args), {i, val -> shellescape(val)})
	let cmd = printf("'clear' Enter \"%s %s %s\" Enter", opts.prg, file, join(args, ' '))
	if s:tmux('display -p "#{window_zoomed_flag}"') == 1
		call s:tmux('resizep -Z')
	end
	if s:tmux('display -p "#{window_panes}"') == 1
		call s:tmux('splitw -v -p 25 -c "#{pane_current_path}"')
		call s:tmux(printf('selectp -T "%s"', opts.pane))
		call s:tmux('selectp -t :.! ')
	end
	let panes = s:tmux('lsp -F "#{pane_id}:#{pane_title}"', 1)
	for [id, title] in map(panes, {i, line -> split(line, ':')})
		if title == opts.pane
			call s:tmux(printf('send -t %s %s', id, cmd))
			if opts.focus
				call s:tmux('selectp -t ' . id)
			end
			return
		end
	endfo
	call s:err(printf("Please run \"selectp -T '%s'\" on the target pane.", opts.pane))
endf
