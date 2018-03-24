
let s:pairs = {'(': ')', '[': ']', '{': '}'}
let s:inv = {')': '(', ']': '[', '}': '{'}

func! objects#items#args(inner)
	call s:select('(', a:inner, v:count1)
endf

func! objects#items#list(inner)
	call s:select('[', a:inner, v:count1)
endf

func! objects#items#dict(inner)
	call s:select('{', a:inner, v:count1)
endf

func! s:select(type, inner, count) abort

	let cursor_pos = getcurpos()[1:2]

	let start = [0, 0]
	let end = [0, 0]
	let skip = "objects#syntax() =~ '\\v^(String|Comment)$'"

	for i in range(1, a:count)
		if searchpair('\V'.a:type, '', '\V'.s:pairs[a:type], 'Wb', skip, line('w0'))
			let start = getcurpos()[1:2]
			norm! %
			let end = getcurpos()[1:2]
			call cursor(start)
		else
			break
		end
	endfo

	call cursor(cursor_pos)

	if start == [0, 0]
		return
	end

	let item_start = start
	let item_end = end
	let stack = []
	let stop = 0

	for nr in range(start[0], end[0])

		let line = getline(nr)
		let start_i = nr == start[0] ? start[1]+1 : 0
		let end_i = nr == end[0] ? end[1]-1 : len(line)

		for i in range(start_i, end_i)

			if objects#syntax(nr, i) =~ '\v^(String|Comment)$'
				continue
			end

			let char = line[i-1]

			if char == ',' && empty(stack)
				if nr < cursor_pos[0] || nr == cursor_pos[0] && i <= cursor_pos[1]
					let item_start = [nr, i]
					continue
				end
				if nr > cursor_pos[0] || nr == cursor_pos[0] && i >= cursor_pos[1]
					let item_end = [nr, i]
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

	" Do nothing when there is no argument/item/etc, not even empty space
	if start[0] == end[0] && start[1] == end[1]-1
		return
	end

	if item_start == start && item_end == end
		call cursor(item_start[0], item_start[1]+1)
		if a:inner
			call search('\S', 'Wc')
			if getcurpos()[1:2] == end
				" when there is no argument/item/etc but only empty space
				call cursor(item_start[0], item_start[1]+1)
			end
		end
		norm! v
		call cursor(item_end[0], item_end[1]-1)
		if a:inner
			call search('\S', 'Wbc')
			if getcurpos()[1:2] == start
				" when there is no argument/item/etc but only empty space
				call cursor(item_end[0], item_end[1]-1)
			end
		end
		return
	end

	if item_start == start
		call cursor(item_start[0], item_start[1]+1)
		if a:inner
			call search('\S', 'Wc')
		end
		norm! v
		call cursor(item_end[0], item_end[1])
		if a:inner
			call search('\S', 'Wb')
		else
			call search('\v\s\ze\S', 'W')
		end
		return
	end

	if item_end == end
		call cursor(item_end[0], item_end[1]-1)
		if a:inner
			call search('\S', 'Wbc')
		end
		norm! v
		call cursor(item_start[0], item_start[1])
		if a:inner
			call search('\S', 'W')
		end
		return
	end

	if a:inner
		call cursor(item_start[0], item_start[1])
		call search('\S', 'W')
		norm! v
		call cursor(item_end[0], item_end[1])
		call search('\S', 'Wb')
	else
		call cursor(item_start[0], item_start[1])
		norm! v
		call cursor(item_end[0], item_end[1])
		call search('\S', 'Wb')
	end

endf
