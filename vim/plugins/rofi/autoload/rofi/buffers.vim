
" rofi#buffers#show([{all:number}]) -> 0
" View all open buffers with Rofi. If {all} is given and it's true, then
" 'normal' unlisted buffers are also displayed.
func! rofi#buffers#show(...) abort

	let all = a:0 > 0 && a:1
	let buffers = s:buffers(all)
	if len(buffers) == 0
		return 0
	end

	let choice = s:rofi(buffers)
	let exitcode = v:shell_error

	" 'choice' will be empty when pressing  -kb-cancel but it will be -1 when
	" pressing -kb-accept-entry with nothing selected
	if empty(choice) || choice == -1
		return 0
	end

	let bufnr = buffers[choice]

	" -kb-custom-7
	" Switch to file search
	if exitcode == 16
		if !rofi#files#edit()
			return rofi#buffers#show(all)
		end
		return 1
	end

	" -kb-custom-6
	" Toggle unlisted buffers
	if exitcode == 15
		return rofi#buffers#show(1 - all)
	end

	" -kb-custom-(4|5)
	" Delete or wipe selected buffer
	if exitcode == 13 || exitcode == 14
		try
			let map = {13: 'bdelete', 14: 'bwipe'}
			exec get(map, exitcode, '') bufnr
			redraw!
			return rofi#buffers#show(all)
		catch /E.*/
			call rofi#err(matchstr(v:exception, '\vE\d+:.*'))
			return 0
		endtry
	end

	" -kb-accept-entry, -kb-custom-(1|2|3)
	" Open the selected buffer in the current window, in a split or in a tab
	if index([0, 10, 11, 12], exitcode) != -1
		let cmdmap = {10: 'split', 11: 'vsplit', 12: 'tab split'}
		exec get(cmdmap, exitcode, '')
		sil exec 'edit' fnameescape(bufname(bufnr))
		return 1
	end

	return 0

endf

" s:rofi({buffers:list}) -> string
func! s:rofi(buffers)

	let lines = min([len(a:buffers), g:rofi_max_lines])
	let selected = max([index(a:buffers, bufnr('%')), 0])
	let options  = "-dmenu -monitor '-2' -p 'buffer ' -i -format i"
	let options .= printf(" -markup-rows -lines %s -selected-row %s", lines, selected)

	let theme = "term-" . &bg
	let style = printf("-width %s -theme '%s'", rofi#width(), theme)

	if len(a:buffers) <= lines
		let style .= " -theme-str 'listview { scrollbar: false; }'"
	end

	if !g:rofi_buffers_inputbar
		let style .= " -theme-str 'mainbox { children: [listview]; }'"
		let options .= " -kb-row-up 'Up,Control+k,k' -kb-row-down 'Down,Control+j,j'"
		let options .= " -kb-accept-entry 'l,Control+d' -kb-cancel 'Escape,q'"
		let options .= " -kb-custom-1 's' -kb-custom-2 'v' -kb-custom-3 't'"
		let options .= " -kb-custom-4 'd' -kb-custom-5 'w'"
		let options .= " -kb-custom-6 'a' -kb-custom-7 'f'"
	else
		let options .= " -kb-custom-1 'Alt+s' -kb-custom-2 'Alt+v' -kb-custom-3 'Alt+t'"
		let options .= " -kb-custom-4 'Alt+d' -kb-custom-5 'Alt+w'"
		let options .= " -kb-custom-6 'Alt+a' -kb-custom-y 'Alt+f'"
	end

	let input = join(s:format_buffers(a:buffers), "\n")
	let cmd = printf("rofi %s %s 2>/dev/null", options, style)
	return get(systemlist(cmd, input), 0, '')

endf

" s:buffers([{all:number}]) -> list
" Return a list of 'normal' buffers (for which the 'buftype' option is empty).
" If {all} is given and it's true, unlisted buffers are also returned.
func! s:buffers(...)
	let all = a:0 > 0 ? a:1 : 0
	let EmptyBuftype = {b -> empty(getbufvar(b, '&buftype'))}
	let Fn = {_, b -> (all && bufexists(b) || buflisted(b)) && EmptyBuftype(b)}
	return filter(range(1, bufnr('$')), Fn)
endf

" s:format_buffers({buffers:list}) -> list
" Format the given list of buffer numbers for Rofi.
func! s:format_buffers(buffers)

	let color_dim = rofi#get_color(g:rofi_color_dim)
	let color_mod = rofi#get_color(g:rofi_color_mod)

	let tails = {}
	for bufnr in a:buffers
		let tail = fnamemodify(bufname(bufnr), ':t')
		let tails[tail] = get(tails, tail) + 1
	endfo

	let lines = []
	for bufnr in a:buffers

		let bufname = bufname(bufnr)
		let path = empty(bufname) ? '' : s:prettify_path(fnamemodify(bufname, ':p'))

		let line = ''

		if empty(bufname)
			let tail = 'unnamed ('.bufnr.')'
		else
			let tail =  fnamemodify(path, ':t')
			if get(tails, tail) > 1
				let tail = join(split(path, '/')[-2:], '/')
			end
		end

		if getbufvar(bufnr, '&mod')
			let line .= printf("<span foreground='%s'>%s</span>", color_mod, tail)
		elseif !buflisted(bufnr)
			let line .= printf("<span foreground='%s'>%s</span>", color_dim, tail)
		else
			let line .= tail
		end

		if path != tail
			let line .= ' ' . printf("<span foreground='%s'>%s</span>", color_dim, path)
		end

		call add(lines, line)

	endfo

	return lines
endf

" s:prettify_path({path:string}) -> string
" Prettify the given {path} by trimming the current working directory.
" If not successful, try to reduce file name to be relative to the home directory.
func! s:prettify_path(path)
	let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
	let path = substitute(path, '\V\^'.$HOME, '~', '')
	return path
endf
