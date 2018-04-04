
let g:explorer#tree#node = {}

" explorer#tree#node.new({path:string}) -> dict
" Create a new node for the given {path}.
func explorer#tree#node.new(path)
	let node = copy(self)
	let node.path = a:path
	let node.info = ''
	let node.decor = ''
	let node.content = []
	let node.parent = {}
	return node
endf

" explorer#tree#node.set_path({path:string}) -> 0
" Set path for the current node.
func explorer#tree#node.set_path(path)
	let self.path = a:path
endf

" explorer#tree#node.filename() -> string
" Return the file name of the current node.
func explorer#tree#node.filename()
	return fnamemodify(self.path, ':t')
endf

" explorer#tree#node.get_content([{max_depth:number}]) -> 0
" Get recursively the directory content of the current node up to
" {max_depth} levels deep. When not given, {max_depth} defaults to 1.
func explorer#tree#node.get_content(...)

	func! s:_get_content(node, lvl, max_depth)
		if a:lvl > a:max_depth
			return
		end
		let a:node.content = []
		for file in s:ls(a:node.path)
			let node = g:explorer#tree#node.new(file.path)
			let node.info = file.info
			let node.decor = file.decor
			let node.parent = a:node
			call add(a:node.content, node)
			if isdirectory(node.path)
				call s:_get_content(node, a:lvl+1, a:max_depth)
			end
		endfo
	endf

	let max_depth = a:0 > 0 ? a:1 : 1
	call s:_get_content(self, 1, max_depth)

endf

" explorer#tree#node.find({test:funcref}) -> dict
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

" explorer#tree#node.do({fn:funcref}) -> 0
" Execute {fn} on the current node and each of its descendants.
func! explorer#tree#node.do(fn)
	func! s:_do(node, fn)
		call call(a:fn, [a:node])
		for node in a:node.content
			call s:_do(node, a:fn)
		endfo
	endf
	return s:_do(self, a:fn)
endf

" explorer#tree#node.render() -> 0
" Render the directory tree in the current buffer.
func! explorer#tree#node.render() abort

	syn clear
	setl modifiable
	sil %delete _

	syn match ExplorerPipe /─/
	syn match ExplorerPipe /├/
	syn match ExplorerPipe /│/
	syn match ExplorerPipe /└/

	let b:explorer.map = {}

	let filters = []
	if g:explorer_filters_active
		call extend(filters, g:explorer_filters)
	end
	if !g:explorer_hidden_files
		call add(filters, {node -> node.filename() !~ '\V\^.'})
	end

	func! s:_print_tree(node, nr, filters, padding, is_last_child)

		let nr = a:nr + 1
		let b:explorer.map[nr] = a:node

		let filename = a:node.filename()

		let links = a:padding . (a:is_last_child ? '└─ ' : '├─ ')

		let line = links . filename

		if a:node.decor =~ '\V\^/'
			call s:highlight('ExplorerDir', nr, len(links), len(links)+len(filename)+2)
		elseif a:node.decor =~ '\V\^*'
			call s:highlight('ExplorerExec', nr, len(links), len(links)+len(filename)+2)
		end
		if a:node.decor =~ '\V->'
			call s:highlight('ExplorerLink', nr, len(links), len(links)+len(filename)+2)
			call s:highlight('ExplorerDim', nr, len(links)+len(filename))
			let line .= a:node.decor
		end

		call setline(nr, line)

		let padding = a:padding . (a:is_last_child ? '   ' : '│  ')

		let nodes = s:filter(a:node.content, a:filters)
		let last = len(nodes)-1
		for i in range(len(nodes))
			let nr = s:_print_tree(nodes[i], nr, a:filters, padding, i == last)
		endfo

		return nr

	endf

	let nr = 1

	let b:explorer.map[nr] = self
	call setline(nr, self.path)
	call s:highlight('ExplorerTitle', nr)

	let nodes = s:filter(self.content, filters)
	let last = len(nodes)-1
	for k in range(len(nodes))
		let nr = s:_print_tree(nodes[k], nr, filters, '', k == last)
	endfo

	call setwinvar(0, "&stl", ' ' . self.path)
	setl nomodifiable

endf

" s:filter({list:list}, {filters:list}) -> list
" Return a list of all the {list} items that satisfy all {filters}.
" {filters} is expected to be a list of Funcrefs.
" The original {list} is not modified.
func! s:filter(list, filters)
	let filtered = []
	for item in a:list
		let add = 1
		for F in a:filters
			if !call(F, [item])
				let add = 0
				break
			end
		endfo
		if add
			call add(filtered, item)
		end
	endfo
	return filtered
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

" s:ls({path:string}) -> list
" Return the parsed content of `ls --dired {path}`.
" Return value structure: [{path, info, decor}, ..]
" Errors are ignored.
func! s:ls(path)

	let flags = '-lhHFA --group-directories-first --dired'
	let lines = systemlist(printf("ls %s %s", flags, shellescape(a:path)))
	if v:shell_error || get(lines, -2) !~ '\v^//DIRED//'
		return []
	end

	let k = 1
	let files = []
	let offsets = map(split(matchstr(lines[-2], '\v^//DIRED//\zs.*')), {-> str2nr(v:val)})
	let start = get(offsets, 0, len(lines[0])) - len(lines[0])
	for i in range(0, len(offsets)-1, 2)
		let file = {}
		let filename = strpart(lines[k], start-1, offsets[i+1] - offsets[i])
		let file.path = explorer#path#join(a:path, filename)
		let file.decor = strpart(lines[k], start-1 + offsets[i+1] - offsets[i])
		let file.info = substitute(s:trim(strpart(lines[k], 0, start-2)), '\v\s\s+', ' ', '')
		call add(files, file)
		let k += 1
	endfo

	return files
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
