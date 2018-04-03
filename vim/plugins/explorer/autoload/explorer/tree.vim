
let g:explorer#tree#node = {}

" explorer#tree#node.new({path:string}) -> {node:dict}
" Create a new node for the given {path}.
func explorer#tree#node.new(path)
	let node = copy(self)
	let node.path = a:path
	let node.filename = fnamemodify(a:path, ':t')
	let node.info = ''
	let node.content = []
	let node.parent = {}
	return node
endf

" explorer#tree#node.get_content() -> {result:number}
" Get directory content of the current node.
" A number is returned to indicate success (1) or failure (0).
func explorer#tree#node.get_content()
	let flags = '-lhHFA --group-directories-first --dired'
	let lines = systemlist(printf("ls %s %s", flags, shellescape(self.path)))
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
		let filename = strpart(lines[n], start-1, offsets[i+1] - offsets[i])
		let path = explorer#path#join(self.path, filename)
		let node = g:explorer#tree#node.new(path)
		let node.meta = strpart(lines[n], start-1 + offsets[i+1] - offsets[i])
		let node.info = substitute(s:trim(strpart(lines[n], 0, start-2)), '\v\s\s+', ' ', '')
		let node.parent = self
		call add(files, node)
		let n += 1
	endfo
	let self.content = files
	return 1
endf

" explorer#tree#node.find({test:funcref}) -> {node:dict}
" Find the first node that satisfies the given test.
" For {node} and each of its descendants, evaluate {test} and when
" the result is true, return that node.
func! explorer#tree#node.find(test)
	func! s:find_node(node, test)
		if call(a:test, [a:node])
			return a:node
		end
		for node in a:node.content
			let node = s:find_node(node, a:test)
			if !empty(node)
				return node
			end
		endfo
		return {}
	endf
	return s:find_node(self, a:test)
endf

" explorer#tree#node.render() -> 0
" Render the directory tree in the current buffer.
func! explorer#tree#node.render() abort

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

	call setline(ln, self.path)
	call s:highlight('ExplorerTitle', ln)

	let topfiles = copy(self.content)
	if !g:explorer_hidden_files
		call filter(topfiles, "v:val['filename'] !~ '\\V\\^.'")
	end

	let last_k = len(topfiles)-1
	for k in range(len(topfiles))
		call s:_print_tree(topfiles[k], '', k == last_k)
	endfo

	call setwinvar(0, "&stl", ' ' . self.path)
	setl nomodifiable

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

" s:highlight({group:string}, {line:number}, [, {start:number}, [, {end:number}]]) -> 0
" Highlight a {line} with the given highlight {group}.
" If neither {start} or {end} are given, the whole line is highlighted.
" If only {start} is given, the line is highlighted starting from the column {start}.
" If only {end} is given, the line is highlighted from {start} to {end}.
func! s:highlight(group, line, ...)
	let start = a:0 > 0 && type(a:1) == v:t_number ? '%>'.a:1.'c.*' : ''
	let end = a:0 > 1 && type(a:2) == v:t_number ? '%<'.a:2.'c' : ''
	let line = '%'.a:line.'l' . (empty(start.end) ? '.*' : '')
	exec printf('syn match %s /\v%s%s%s/', a:group, line, start, end)
endf

" s:prettify_path({path:string}) -> string
" Prettify the given {path} by trimming the current working directory.
" If not successful, try to reduce file name to be relative to the
" home directory (much like using ':~')
func! s:prettify_path(path)
	let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
	return substitute(path, '\V\^'.$HOME, '~', '')
endf

" s:trim({s:string}) -> string
" Trim leading and trailing whitespaces from a string {s}.
func! s:trim(s)
	return substitute(a:s, '\v(^\s+|\s+$)', '', 'g')
endf
