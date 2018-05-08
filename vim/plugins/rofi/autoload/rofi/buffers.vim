
" rofi#buffers#show([{all:number}]) -> 0
" View all open buffers with Rofi. If {all} is given and it's true, then
" 'normal' unlisted buffers are also displayed.
func! rofi#buffers#show(...) abort

	let all = a:0 > 0 && a:1
	let buffers = s:buffers(all)
	if empty(buffers)
		return rofi#err("No more buffers")
	end

	let choice = s:rofi(buffers)
	let exitcode = v:shell_error

	" 'choice' will be empty when pressing  -kb-cancel but it will be -1 when
	" pressing -kb-accept-entry with nothing selected
	if empty(choice) || choice == -1
		return
	end

	let bufnr = buffers[choice]

	" -kb-accept-entry -> 0 (open in the current window)
	" -kb-custom-1 -> 10 (split window horizontally)
	" -kb-custom-2 -> 11 (split window verically)
	" -kb-custom-3 -> 12 (open in a new tab)
	" -kb-custom-4 -> 13 (delete buffer)
	" -kb-custom-5 -> 14 (wipe buffer)
	" -kb-custom-6 -> 15 (toggle unlisted buffers)

	if exitcode == 15

		call rofi#buffers#show(1 - all)

	elseif exitcode == 13 || exitcode == 14

		try
			let map = {13: 'bdelete', 14: 'bwipe'}
			exec get(map, exitcode, '') bufnr
			redraw!
			call rofi#buffers#show(all)
		catch /E.*/
			call rofi#err(matchstr(v:exception, '\vE\d+:.*'))
		endtry

	else

		let cmdmap = {10: 'split', 11: 'vsplit', 12: 'tab split'}
		exec get(cmdmap, exitcode, '')
		sil exec 'edit' fnameescape(bufname(bufnr))

	end

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
		let options .= " -kb-custom-6 'a'"
	else
		let options .= " -kb-custom-1 'Alt+s' -kb-custom-2 'Alt+v' -kb-custom-3 'Alt+t'"
		let options .= " -kb-custom-4 'Alt+d' -kb-custom-5 'Alt+w'"
		let options .= " -kb-custom-6 'Control+a'"
	end

	let input = join(s:format_buffers(a:buffers), "\n")
	let cmd = printf("rofi %s %s 2>/dev/null", options, style)
	return get(systemlist(cmd, input), 0, '')

endf

" s:buffers([{all:number}]) -> list
" Return a list of 'normal' buffers (for which the 'buftype' option is empty).
" If {all} is given and it's true, unlisted buffers are also returned.
func! s:buffers(...)
	if a:0 > 0 && a:1
		let Fn = {i, nr -> bufexists(nr) && empty(getbufvar(nr, '&buftype'))}
	else
		let Fn = {i, nr -> buflisted(nr) && empty(getbufvar(nr, '&buftype'))}
	end
	return filter(range(1, bufnr('$')), Fn)
endf

" s:format_buffers({buffers:list}) -> list
" Format the given list of buffer numbers for Rofi.
func! s:format_buffers(buffers)

	let patt = '\v#[0-9a-fA-F]+'
	let colors = {
		\ 'dim': matchstr(execute('hi ' . g:rofi_color_dim), patt),
		\ 'mod': matchstr(execute('hi ' . g:rofi_color_mod), patt),
	\ }

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
			let line .= printf("<span foreground='%s'>%s</span>", colors.mod, tail)
		elseif !buflisted(bufnr)
			let line .= printf("<span foreground='%s'>%s</span>", colors.dim, tail)
		else
			let line .= tail
		end

		if path != tail
			let line .= ' ' . printf("<span foreground='%s'>%s</span>", colors.dim, path)
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
