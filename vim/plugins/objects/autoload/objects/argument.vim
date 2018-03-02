
let s:pairs = {'(': ')', '[': ']', '{': '}'}
let s:invpairs = {')': '(', ']': '[', '}': '{'}

" Select the current argument/parameter
func! objects#argument#select(inner)

	let curpos = getcurpos()[1:2]

	let skip = "objects#syntax() =~ '\\v^(String|Comment)$'"
	let start = searchpairpos('(', '', ')', 'Wbnc', skip)
	if start == [0, 0]
		return
	end
	let end = searchpairpos('(', '', ')', 'Wn', skip)
	if end == [0, 0]
		return
	end

	let stack = []
	let argstart = start
	let argend = end
	let stop = 0

	for nr in range(start[0], end[0])

		let line = getline(nr)

		let start_i = 0
		let end_i = len(line)

		if nr == start[0]
			let start_i = start[1]+1
		end
		if nr == end[0]
			let end_i = end[1]-1
		end

		for i in range(start_i, end_i)
			if objects#syntax(nr, i) =~ '\v^(String|Comment)$'
				continue
			end
			let char = line[i-1]
			if char == ',' && empty(stack)
				if nr < curpos[0] || nr == curpos[0] && i <= curpos[1]
					let argstart = [nr, i]
					continue
				end
				if nr > curpos[0] || nr == curpos[0] && i >= curpos[1]
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

	if argstart == curpos && argend == curpos
		return
	end

	call s:select(start, end, argstart, argend, a:inner)

endf

func! s:select(start, end, argstart, argend, inner)

	if a:argstart == a:start
		call cursor(a:argstart[0], a:argstart[1]+1)
		norm! v
		if a:inner
			call cursor(a:argend[0], a:argend[1])
			call search('\S', 'Wb')
		else
			call cursor(a:argend[0], a:argend[1])
			call search('\v\s\ze\_S', 'We')
		end
		return
	end

	if a:argend == a:end
		call cursor(a:argend[0], a:argend[1]-1)
		norm! v
		if a:inner
			call cursor(a:argstart[0], a:argstart[1])
			call search('\S', 'W')
		else
			call cursor(a:argstart[0], a:argstart[1])
		end
		return
	end

	if a:inner
		call cursor(a:argstart[0], a:argstart[1])
		call search('\S', 'W')
		norm! v
		call cursor(a:argend[0], a:argend[1])
		call search('\S', 'Wb')
	else
		call cursor(a:argstart[0], a:argstart[1])
		norm! v
		call cursor(a:argend[0], a:argend[1])
		call search('\S', 'Wb')
	end

endf
