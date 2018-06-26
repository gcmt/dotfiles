
" rofi#files#edit([{filter:string}]) -> 0
" Search for files in the current working directory.
" If a {filter} is given, the rofi input bar will be populate with it.
func! rofi#files#edit(...) abort

	let files = system('rg --files')
	if empty(files)
		return 0
	end

	let filter = a:0 > 0 && type(a:1) == v:t_string ? a:1 : ''
	let path = s:rofi(files, filter)
	let exitcode = v:shell_error
	if empty(path)
		return 0
	end

	let map = {0: 'edit', 10: 'split', 11: 'vsplit', 12: 'tabedit'}
	if !empty(path) && has_key(map, exitcode)
		exec get(map, exitcode) fnameescape(path)
		return 1
	end

	return 0

endf

" s:rofi({files:list}[, {filter:string}]) -> string
func! s:rofi(files, ...)

	let options = "-dmenu -monitor '-2' -p 'edit ' -no-custom -i -matching regex"

	if a:0 > 0 && type(a:1) == v:t_string
		let options .= printf(" -filter '%s'", a:1)
	end

	let theme = "term-" . &bg
	let style = printf("-theme '%s'", theme)
	let style .= " -theme-str 'listview { fixed-height: true; }'"
	let style .= printf(" -theme-str 'window { width: %s%%; }'", rofi#width())

	let lines = min([len(a:files), g:rofi_max_lines])
	let style .= printf(" -theme-str 'listview { lines: %s; }'", lines)

	if len(a:files) <= lines
		let style .= " -theme-str 'listview { scrollbar: false; }'"
	end

	let options .= " -kb-accept-entry 'Control+d,Control+l,Control+m,Return'"
	let options .= " -kb-custom-1 'Alt+s' -kb-custom-2 'Alt+v' -kb-custom-3 'Alt+t'"

	let cmd = printf("rofi %s %s 2>/dev/null", options, style)
	return get(systemlist(cmd, a:files), 0, '')

endf
