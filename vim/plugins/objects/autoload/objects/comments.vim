
" FIXME:
" - Properly handle multiline comments (multiple paragraphs, etc.)


let s:default_options = {
\ }


func! s:options(options)
	let globals = get(g:objects_options, 'comments', {})
	return objects#merge_dicts(s:default_options, globals, a:options)
endf


" objects#comments#select({options:dict}, {visual:bool}, {count:number}) -> 0
" Selects the comment at the current cursor position.
func! objects#comments#select(options, visual, count)

	let curpos = getcurpos()[1:2]

	" check for a comment at the end of the line
	if objects#synat(line('.'), col('.')) != 'Comment'
		let curpos[1] = strchars(getline(curpos[0]))
	end

	let start = s:find_start(curpos)
	if start == [0, 0]
		return
	end

	let end = s:find_end(curpos, start)
	if end == [0, 0]
		return
	end

	call cursor(start)
	if start[0] == end[0] && start[1] != 1 && getline(start[0])[:start[1]-2] !~ '\v^\s*$'
		norm! v
	else
		norm! V
	end
	call cursor(end)

endf


" s:find_start({curpos:list}) -> [linenr, colnr]
" Returns comment starting position.
func! s:find_start(curpos)
	let start = [0, 0]
	for line in reverse(range(1, a:curpos[0]))
		if line == a:curpos[0]
			let columns = reverse(range(1, a:curpos[1]))
		else
			let columns = reverse(range(1, strchars(getline(line))))
		end
		if empty(columns)
			return start
		end
		for col in columns
			if objects#synat(line, col) != 'Comment' && s:charat(getline(line), col-1) !~ '\s'
				if start[0] != a:curpos[0] && start[1] != 1
					let start = [start[0]+1, 1]
				end
				return start
			end
			let start = [line, col]
		endfo
	endfo
	return start
endf


" s:find_end({curpos:list}, {start:list}) -> [linenr, colnr]
" Returns comment ending position.
func! s:find_end(curpos, start)
	if a:curpos[0] == a:start[0] && a:start[1] != 1
		" inline comment does not span the whole line
		return [a:start[0], strchars(getline(a:curpos[0]))]
	end
	let end = [0, 0]
	for line in range(a:curpos[0], line('$'))
		if line == a:curpos[0]
			let columns = range(a:curpos[1], strchars(getline(a:curpos[0])))
		else
			let columns = reverse(range(1, strchars(getline(line))))
		end
		if empty(columns)
			return end
		end
		for col in columns
			if objects#synat(line, col) != 'Comment' && s:charat(getline(line), col-1) !~ '\s'
				return end
			end
		endfo
		let end = [line, strchars(getline(line))]
	endfo
	return end
endf


" s:charat({line:string}, {col:number}) -> char
" Returns the character at `col` column.
func! s:charat(line, col)
	return nr2char(strgetchar(a:line, a:col))
endf
