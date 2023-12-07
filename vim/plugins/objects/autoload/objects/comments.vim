

let s:default_options = {
	\ 'inner': 0,
	\ 'content': 0,
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

	while 1

		if objects#synat(line('.'), col('.')) != 'Comment'
			let curpos[1] += 1
			if curpos[1] > strchars(getline('.'))
				break
			else
				continue
			end
		end

		let start = [0, 0]
		let end = [0, 0]

		" detect multiline comment
		let skip = "objects#synat(line('.'), col('.')) != 'Comment'"
		let start = searchpairpos('/\*', '', '\*/', 'Wcnb', skip)
		let end = searchpairpos('/\*', '', '\*/', 'Wcn', skip)
		let end[1] = end[1] ? end[1]+1 : 0

		if start[0] == 0 || end[0] == 0
			" echo "multiline not found"
			" detect inline comment or block
			let start = s:find_start(curpos)
			let end = s:find_end(curpos)
		end

		if start[0] == 0 || end[0] == 0
			break
		end

		" echo start end

		let startln = getline(start[0])
		let endln = getline(end[0])
		let isblock = strcharpart(startln, 0, start[1]-1) =~ '\v^\s*$' && end[1] == strchars(endln)

		call cursor(start)

		if options.content
			" select only the comment content
			if search('\v\S+', "Wce", start[0])
				if col('.') != col('$')-1
					call search('\S', "We", start[0])
				else
					norm! +
				end
			end
		end

		exec "norm!" (isblock ? "V" : "v")

		call cursor(end)

		if isblock && !options.inner && !options.content
			" select all empty lines after the comment block
			let line = nextnonblank(end[0]+1)
			let line = line ? line-1 : line('$')
			call cursor([line, 1])
		end

		if options.content && search('\V*/', 'Wncb', end[0])
			" select only the comment content
			if search('\v\s*\*/', "Wcb", end[0])
				if col('.') != 1
					call search('\S', 'Wb', end[0])
				else
					norm! kg_
				end
			end
		end

		if a:visual && options.content
			" move the cursor at the start of the comment
			norm! o
		end

		break

	endw

endf

" s:search_comment({linenr:number}, {inline:bool}) -> [colnr, colnr]
" Search for comments on the target line. If {inline} is false, the search is
" aborted as soon as a non comment character is encountered.
func! s:search_comment(linenr, inline)
	let line = getline(a:linenr)
	for [col, char] in map(split(line, '\zs'), {i, val -> [i+1, val]})
		if objects#synat(a:linenr, col) == 'Comment'
			" since we are detecting inline comments, we can consider the rest
			" of the line also a comment
			return [col, strchars(line)]
		elseif !a:inline && char =~ '\s'
			" stop early when encountering a non-comment unless it's a space
			return [0, 0]
		end
		let col += 1
	endfo
	return [0, 0]
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
