
" Render the directory tree.
func! explorer#tree#render() abort

	if &filetype != 'explorer'
		throw "Explorer: &filetype must be 'explorer'"
	end

	syn clear
	setl modifiable
	sil %delete _

	syn match ExplorerPipe /─/
	syn match ExplorerPipe /└/
	syn match ExplorerPipe /├/
	syn match ExplorerPipe /│/

	let ln = 1
	let b:explorer.map = {}

	func! s:_print_tree(node, padding, is_last_child) closure

		let ln += 1
		let b:explorer.map[ln] = {'path': a:node.path, 'node': a:node}

		let links = a:padding . (a:is_last_child ? '└─ ' : '├─ ')

		let line = links . a:node.filename

		if a:node.meta =~ '\V\^/'
			call s:highlight('ExplorerDir', ln, len(links), len(links)+len(a:node.filename)+2)
		elseif a:node.meta =~ '\V\^*'
			call s:highlight('ExplorerExec', ln, len(links), len(links)+len(a:node.filename)+2)
		end
		if a:node.meta =~ '\V->'
			call s:highlight('ExplorerLink', ln, len(links), len(links)+len(a:node.filename)+2)
			call s:highlight('ExplorerDim', ln, len(links)+len(a:node.filename))
			let line .= a:node.meta
		end

		call setline(ln, line)

		let padding = a:padding . (a:is_last_child ? '   ' : '│  ')

		let files = copy(a:node.content)
		if !g:explorer_hidden_files
			call filter(files, "v:val['filename'] !~ '\\V\\^.'")
		end

		let last_i = len(files)-1
		for i in range(len(files))
			call s:_print_tree(files[i], padding, i == last_i)
		endfo

	endf

	call setline(ln, b:explorer.tree.path)
	call s:highlight('ExplorerTitle', ln)

	let topfiles = copy(b:explorer.tree.content)
	if !g:explorer_hidden_files
		call filter(topfiles, "v:val['filename'] !~ '\\V\\^.'")
	end

	let last_k = len(topfiles)-1
	for k in range(len(topfiles))
		call s:_print_tree(topfiles[k], '', k == last_k)
	endfo

	call setwinvar(0, "&stl", ' ' . b:explorer.tree.path)
	setl nomodifiable

endf

" Get directory content of the given node.
func! explorer#tree#get_content(node)
	let flags = '-lhHFA --group-directories-first --dired'
	let lines = systemlist(printf("ls %s %s", flags, shellescape(a:node.path)))
	if v:shell_error
		return 0
	end
	let offsets = []
	for line in lines
		if line =~ '\v^//DIRED//'
			let offsets = map(split(matchstr(line, '\v^//DIRED//\zs.*')), {-> str2nr(v:val)})
			break
		end
	endfo
	let n = 1
	let files = []
	let start = get(offsets, 0, len(lines[0])) - len(lines[0])
	for i in range(0, len(offsets)-1, 2)
		let file = {}
		let file['info'] = substitute(strpart(lines[n], 0, start-2), '\v^\s+', '', '')
		let file['info'] = substitute(file['info'], '\v\s\s+', ' ', '')
		let file['filename'] = strpart(lines[n], start-1, offsets[i+1] - offsets[i])
		let file['meta'] = strpart(lines[n], start-1 + offsets[i+1] - offsets[i])
		let file['path'] = explorer#path#join(a:node.path, file.filename)
		let file['parent'] = a:node
		let file['content'] = []
		call add(files, file)
		let n += 1
	endfo
	let a:node.content = files
	return 1
endf

" Find the first node that satisfies the given a:test.
" a:test is expected to be a Funcref.
func! explorer#tree#find_node(node, test)
	if call(a:test, [a:node])
		return a:node
	end
	for node in a:node.content
		let node = explorer#tree#find_node(node, a:test)
		if !empty(node)
			return node
		end
	endfo
	return {}
endf

" Move the cursor to the given file.
func! explorer#tree#goto(path)
	for [line, entry] in items(b:explorer.map)
		if a:path == entry.path
			exec line
			norm! 0
			return 1
		end
	endfo
	return 0
endf

" Highlight a line with the given highlight group.
" Start and end column might be given as well.
func! s:highlight(group, line, ...)
	let start = a:0 > 0 && type(a:1) == v:t_number ? '%>'.a:1.'c.*' : ''
	let end = a:0 > 1 && type(a:2) == v:t_number ? '%<'.a:2.'c' : ''
	let line = '%'.a:line.'l' . (empty(start.end) ? '.*' : '')
	exec printf('syn match %s /\v%s%s%s/', a:group, line, start, end)
endf

" Prettify the given path.
" Wherever possible, trim the current working directory.
func! s:prettify_path(path)
	let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
	return substitute(path, '\V\^'.$HOME, '~', '')
endf
