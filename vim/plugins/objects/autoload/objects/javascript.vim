
func! objects#javascript#function(inner)

	let curpos = getcurpos()[1:2]
	let skip = "objects#syntax() =~ '\\v^(String|Comment)$'"

	let match = {"start": [0, 0], "body": [0, 0], "end": [0, 0]}
	for i in range(1, v:count1)

		let candidate = {"start": [0, 0], "body": [0, 0], "end": [0, 0]}
		while 1

			let candidate = s:detect_inline_arrow_function()
			if candidate.start != [0, 0]
				let match = candidate
				call cursor(match.start[0], max([match.start[1]-1, 1]))
				break
			end

			if i == 1 && search('{', 'W', line('.')) || searchpair('{', '', '}', 'Wb', skip, line('w0'))
				let candidate.body = getcurpos()[1:2]
				norm! %
				let candidate.end = getcurpos()[1:2]
			else
				break
			end

			" detect arrow function
			call cursor(candidate.body)
			if (search('\V\w\+\s\*=>\s\*\%'.(candidate.body[1]).'c{', 'Wb', line('.')) ||
				\ search('\V)\s\*=>\s\*\%'.(candidate.body[1]).'c{', 'Wb', line('.')) && searchpair('(', '', ')', 'Wb', skip)) &&
				\ (curpos[0] != line('.') || curpos[0] == line('.') && curpos[1] >= col('.'))
				let candidate.start = getcurpos()[1:2]
				break
			end

			" detect regular function
			call cursor(candidate.body)
			if search('\V)\s\*\%'.(candidate.body[1]).'c{', 'Wb', line('.')) &&
				\ searchpair('(', '', ')', 'Wb', skip) &&
				\ search('\v(async\s+)?<function>', 'Wb', line('.')) &&
				\ (curpos[0] != line('.') || curpos[0] == line('.') && curpos[1] >= col('.'))
				let candidate.start = getcurpos()[1:2]
				break
			end

			" detect short form and getter/setters
			call cursor(candidate.body)
			if search('\V)\s\*\%'.(candidate.body[1]).'c{', 'Wb', line('.')) &&
				\ searchpair('(', '', ')', 'Wb', skip) &&
				\ search('\v^\s*\zs((get|set)\s+)?[*A-Za-z$_][0-9A-Za-z$_]+\s*%'.col('.').'c\(', 'Wb', line('.')) &&
				\ getline('.') !~ '\v^\s*(for|while|if)>' &&
				\ (curpos[0] != line('.') || curpos[0] == line('.') && curpos[1] >= col('.'))
				let candidate.start = getcurpos()[1:2]
				break
			end

			" detect computed property names
			call cursor(candidate.body)
			if search('\V)\s\*\%'.(candidate.body[1]).'c{', 'Wb', line('.')) &&
				\ searchpair('(', '', ')', 'Wb', skip) &&
				\ search('\v^\s*\zs((get|set)\s+)?\[.*\]\s*%'.col('.').'c\(', 'Wb', line('.')) &&
				\ (curpos[0] != line('.') || curpos[0] == line('.') && curpos[1] >= col('.'))
				let candidate.start = getcurpos()[1:2]
				break
			end

			call cursor(candidate.body)

		endw

		if candidate.start == [0, 0]
			break
		end

		let match = candidate
		call cursor(match.start[0], max([match.start[1]-1, 1]))

	endfo

	if match.start == [0, 0]
		call cursor(curpos)
		return
	end

	if a:inner
		call cursor(match.body)
		norm! v
		call cursor(match.end)
	else
		call cursor(match.start)
		norm! v
		call cursor(match.end)
	end

endf

func! s:detect_inline_arrow_function()

	let pos = getcurpos()[1:2]
	let match = {"start": [0, 0], "body": [0, 0], "end": [0, 0]}

	norm! 0
	while search('\V=>\s\*\S', 'e', line('.'))

		let candidate = {"start": [0, 0], "body": [0, 0], "end": [0, 0]}
		let candidate.body = getcurpos()[1:2]

		let stack = []
		let pairs = {'(': ')', '[': ']', '{': '}'}
		let line = getline('.')

		for i in range(col('.'), col('$')-1)
			if objects#syntax(line('.'), i) =~ 'String'
				continue
			end
			let char = line[i-1]
			if char =~ '\v(,|;|\)|\]|})' && empty(stack)
				let candidate.end = [line('.'), i-1]
				break
			end
			if has_key(pairs, char)
				call add(stack, char)
			elseif get(pairs, get(stack, -1, ''), '') == char
				call remove(stack, -1)
			end
		endfo

		call cursor(candidate.body)
		let skip = "objects#syntax() =~ '\\v^(String|Comment)$'"
		if (search('\V\w\+\s\*=>\s\*\%'.(candidate.body[1]).'c\S', 'Wb', line('.')) ||
			\ search('\V)\s\*=>\s\*\%'.(candidate.body[1]).'c\S', 'Wb', line('.')) && searchpair('(', '', ')', 'Wb', skip))
			let candidate.start = getcurpos()[1:2]
		end

		if candidate.start == [0, 0] || candidate.end == [0, 0]
			break
		end

		if pos[1] >= candidate.start[1] && pos[1] <= candidate.end[1]
			let match = candidate
		end

		call cursor(candidate.body)
	endw

	call cursor(pos)
	return match
endf
