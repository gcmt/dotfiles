
func python#formatter#format_current_file()
	let start = reltime()
	let view_save = winsaveview()
	let content = join(getline(1, "$"), "\n")
	let cmd = 'black --quiet -'
	let out = systemlist(cmd, content)
	if v:shell_error == 123
		let cmd = 'black --quiet --check -'
		call _err(trim(system(cmd, content)))
		return
	end
	if v:shell_error
		call _err(join(out, "\n"))
		return
	end
	sil %delete _
	call setline(1, out)
	call winrestview(view_save)
	let elapsed = reltime(start)
	let seconds = substitute(reltimestr(elapsed), '\v\s+', '', 'g')
	echo printf("Formatted in %ss", seconds)
	sil! ALELint
endf
