
let s:pairs = {'(': ')', '[': ']', '{': '}'}
let s:invpairs = {')': '(', ']': '[', '}': '{'}

" Select the current function argument/parameter
func! objects#list#argument(inner)

	let skip = "objects#syntax() =~ '\\v^(String|Comment)$'"
	let start = searchpairpos('(', '', ')', 'Wbnc', skip, line('w0'))
	let end = searchpairpos('(', '', ')', 'Wn', skip, line('w$'))

	if start != [0, 0] && end != [0, 0]
		call s:select(getcurpos()[1:2], start, end, a:inner)
	end

endf

" Select the current list/dictionary item
func! objects#list#item(inner)

	let skip = "objects#syntax() =~ '\\v^(String|Comment)$'"
	let start_a = searchpairpos('\[', '', '\]', 'Wbnc', skip, line('w0'))
	let end_a = searchpairpos('\[', '', '\]', 'Wn', skip, line('w$'))
	let start_b = searchpairpos('{', '', '}', 'Wbnc', skip, line('w0'))
	let end_b = searchpairpos('{', '', '}', 'Wn', skip, line('w$'))

	" find smallest text object
	let start = [0, 0]
	let end = [0, 0]
	let size = v:null
	for [start_, end_] in [[start_a, end_a], [start_b, end_b]]
		if start_ != [0, 0] && end_ != [0, 0]
			let size_ = s:size(start_, end_)
			if size == v:null || size_ < size
				let size = size_
				let start = start_
				let end = end_
			end
		end
	endfo

	if start != [0, 0] && end != [0, 0]
		call s:select(getcurpos()[1:2], start, end, a:inner)
	end

endf

" To return the size of a text object
func! s:size(start, end)
	if a:start[0] == a:end[0]
		return a:end[1] - a:start[1] + 1
	end
	let size = len(getline(a:start[0])) - a:start[1] + a:end[1] + 1
	let size += winwidth(0) * (a:end[0] - a:start[0] - 1)
	return size
endf

func! s:select(curpos, start, end, inner)

	let stack = []
	let argstart = a:start
	let argend = a:end
	let stop = 0

	for nr in range(a:start[0], a:end[0])

		let line = getline(nr)

		let start_i = 0
		let end_i = len(line)

		if nr == a:start[0]
			let start_i = a:start[1]+1
		end
		if nr == a:end[0]
			let end_i = a:end[1]-1
		end

		for i in range(start_i, end_i)
			if objects#syntax(nr, i) =~ '\v^(String|Comment)$'
				continue
			end
			let char = line[i-1]
			if char == ',' && empty(stack)
				if nr < a:curpos[0] || nr == a:curpos[0] && i <= a:curpos[1]
					let argstart = [nr, i]
					continue
				end
				if nr > a:curpos[0] || nr == a:curpos[0] && i >= a:curpos[1]
					let argend = [nr, i]
					let stop = 1
					break
				end
			end
			if has_key(s:pairs, char)
				call add(stack, char)
				continue
			end
			if has_key(s:invpairs, char) && get(stack, -1, '') == s:invpairs[char]
				call remove(stack, -1)
				continue
			end
		endfo

		if stop
			break
		end

	endfo

	if argstart == a:curpos && argend == a:curpos
		return
	end

	if argstart == a:start && argend == a:end
		call cursor(argstart[0], argstart[1]+1)
		norm! v
		call cursor(argend[0], argend[1]-1)
		return
	end

	if argstart == a:start
		call cursor(argstart[0], argstart[1]+1)
		norm! v
		if a:inner
			call cursor(argend[0], argend[1])
			call search('\S', 'Wb')
		else
			call cursor(argend[0], argend[1])
			call search('\v\s\ze\S', 'W')
		end
		return
	end

	if argend == a:end
		call cursor(argend[0], argend[1]-1)
		norm! v
		if a:inner
			call cursor(argstart[0], argstart[1])
			call search('\S', 'W')
		else
			call cursor(argstart[0], argstart[1])
		end
		return
	end

	if a:inner
		call cursor(argstart[0], argstart[1])
		call search('\S', 'W')
		norm! v
		call cursor(argend[0], argend[1])
		call search('\S', 'Wb')
	else
		call cursor(argstart[0], argstart[1])
		norm! v
		call cursor(argend[0], argend[1])
		call search('\S', 'Wb')
	end

endf
