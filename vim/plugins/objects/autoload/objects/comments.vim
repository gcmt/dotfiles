
" FIXME:
" - Properly handle multiline comments (multiple paragraphs, etc.)


let s:default_options = {
	\ 'inner': 0,
\ }


func! s:options(options)
	let globals = get(g:objects_options, 'comments', {})
	return objects#merge_dicts(s:default_options, globals, a:options)
endf


" objects#comments#select({options:dict}, {visual:bool}, {count:number}) -> 0
" Selects the comment at the current cursor position.
func! objects#comments#select(options, visual, count)

	let options = s:options(a:options)
	let curpos = getcurpos()[1:2]

	" check for a comment at the end of the line
	if objects#synat(line('.'), col('.')) != 'Comment'
		let curpos[1] = strchars(getline(curpos[0]))
	end

	let start = s:find_start(curpos)
	if start == [0, 0]
		return
	end

	let end = s:find_end(curpos)
	if end == [0, 0]
		return
	end

	call cursor(start)
	if start[0] == end[0] && options.inner
		" don't select any space preceding the comment
		call search('\S', "Wc", start[0])
	end
	if start[0] == end[0] && (start[1] != 1 || options.inner)
		norm! v
	else
		norm! V
	end
	call cursor(end)
	if start[0] != end[0] && !options.inner
		" select all empty lines after the comment block
		let line = nextnonblank(end[0]+1)
		let line = line ? line-1 : line('$')
		call cursor([line, 1])
	end

endf

" s:search_comment({linenr:number}, {inline:bool}) -> [colnr, colnr]
" Search for comments on the target line. If {inline} is false, the search is
" aborted as soon as a non comment character is encountered.
func! s:search_comment(linenr, inline)
	let columns = split(getline(a:linenr), '\zs')
	if empty(columns)
		return [0, 0]
	end
	let col = 1
	let j = 0
	while col <= len(columns)
		if columns[col-1] =~ '\s'
			" consider any space before the comment as part of the comment
			" itself
			let j = j ? j : col
		elseif objects#synat(a:linenr, col) == 'Comment'
			return [(j ? j : col), len(columns)]
		elseif !a:inline
			return [0, 0]
		else
			let j = 0
		end
		let col += 1
	endw
endf

" s:find_start({curpos:list}) -> [linenr, colnr]
" Returns comment starting position.
func! s:find_start(curpos)
	let start = [0, 0]
	let line = a:curpos[0]
	while line > 0
		let inline = line == a:curpos[0]
		let edges = s:search_comment(line, inline)
		if edges[0] == 0
			break
		end
		let start = [line, edges[0]]
		if inline && edges[0] != 1
			break
		end
		let line -= 1
	endw
	return start
endf

" s:find_end({curpos:list}) -> [linenr, colnr]
" Returns comment ending position.
func! s:find_end(curpos)
	let end = [0, 0]
	let line = a:curpos[0]
	while line <= line('$')
		let inline = line == a:curpos[0]
		let edges = s:search_comment(line, inline)
		if edges[0] == 0
			break
		end
		let end = [line, edges[1]]
		if inline && edges[0] != 1
			break
		end
		let line += 1
	endw
	return end
endf
