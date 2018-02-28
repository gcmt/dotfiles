
func! s:set_statusline(path)
	let hidden_flag = g:explorer_hidden_files ? '[H] ' : ''
	let stl = ' ' . hidden_flag . substitute(a:path, $HOME, '~', '')[:-1] . '%=explorer '
	call setwinvar(0, '&stl', stl)
endf

func! explorer#buffer#render(path) abort

	if !exists('b:explorer')
		throw "Explorer: not an explorer buffer"
	end

	let [files, err] = explorer#utils#ls(a:path, g:explorer_hidden_files)
	if !empty(err)
		return explorer#err(err)
	end

	let b:explorer.dir = a:path
	call s:set_statusline(a:path)

	syntax clear
	setl modifiable
	sil %delete _

	let max_length = 0
	for [fname, _] in files
		if strlen(fname) > max_length
			let max_length = strlen(fname)
		end
	endfo

	let meta_start = max_length + 4
	exec 'syn match ExplorerDim /\v%>'.meta_start.'c.*/'

	let text = []
	let linenr = 1
	for [fname, meta] in files
		let b:explorer.table[linenr] = fname
		let line = fname
		if meta.perms[0] == 'd'
			let line .= '/'
			exec 'syn match ExplorerDir /\v%'.linenr.'l.%<'.(len(line)+2).'c/'
		end
		let line .= repeat(' ', meta_start - len(line))
		let line .= ',' . meta.perms
		let line .= ',' . meta.nlinks
		let line .= ',' . meta.user
		let line .= ',' . meta.group
		let line .= ',' . meta.size
		let line .= ',' . meta.modtime
		let line .= !empty(meta.link) ? ',-> ' . meta.link : ''
		call add(text, line)
		let linenr += 1
	endfo

	call setline(1, text)

	1,$!column -t -s ',' -o '  '

	setl nomodifiable

endf

