
func! explorer#utils#set_cursor(path)
	norm! gg
	if search('\V\^' . fnamemodify(a:path, ':t') . '/\?\s')
		norm! zz
	end
endf

func! explorer#utils#ls(path, hidden)

	let out = systemlist(printf("ls %s -lAh --group-directories-first", shellescape(a:path)))
	if v:shell_error
		return [[], out[0]]
	end

	let content = []

	for line in out[1:]

		let m = matchlist(line, '\v^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\w\w\w\s+\d\d?\s+\d\d:\d\d)\s+(.*)')
		call filter(m, '!empty(v:val)')
		if empty(m)
			" echom "line didn't match >>" line
			continue
		end

		let link = ''
		let fname = m[7]

		if fname =~ '\V->'
			let link = matchstr(fname, '\V->\s\+\zs\.\*')
			let fname = substitute(fname, '\V\s\+->\.\*', '', '')
		end

		if fname[0] == '.' && !a:hidden
			continue
		end

		if fname =~# '\v('.join(split(g:explorer_hide, ','), '|').')'
			continue
		end

		let file = [fname, {
			\ 'fname': fname,
			\ 'link': link,
			\ 'perms': m[1],
			\ 'nlinks': m[2],
			\ 'user': m[3],
			\ 'group': m[4],
			\ 'size': m[5],
			\ 'modtime': m[6],
		\ }]

		call add(content, file)

	endfo

	return [content, '']
endf
