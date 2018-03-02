
let s:pairs = {'(': ')', '[': ']', '{': '}'}
let s:inv = {')': '(', ']': '[', '}': '{'}

func! objects#list#item(p, inner) abort
	let skip = "objects#syntax() =~ '\\v^(String|Comment)$'"
	let start = searchpairpos('\V'.a:p, '', '\V'.s:pairs[a:p], 'Wbnc', skip, line('w0'))
	let end = searchpairpos('\V'.a:p, '', '\V'.s:pairs[a:p], 'Wn', skip, line('w$'))
	if start != [0, 0] && end != [0, 0]
		call s:select(getcurpos()[1:2], start, end, a:inner)
	end
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
			if has_key(s:inv, char) && get(stack, -1, '') == s:inv[char]
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
