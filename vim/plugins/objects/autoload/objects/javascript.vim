
func! objects#javascript#function(inner, leftside)

	let curpos = getcurpos()[1:2]
	let skip = "objects#cursyn() =~ '\\v^(String|Comment)$'"

	let match = {"start": [0, 0], "body": [0, 0], "end": [0, 0]}
	for i in range(1, v:count1)

		let candidate = {"start": [0, 0], "body": [0, 0], "end": [0, 0]}
		let k = 0

		while 1

			let k += 1

			let candidate = s:detect_inline_arrow_function()
			if candidate.start != [0, 0]
				let match = candidate
				call cursor(match.start[0], max([match.start[1]-1, 1]))
				break
			end

			if i == 1 && k == 1
				" Search the start of the function body when the cursor is inside
				" the function signature
				if search('\v(async\s+)?<function>', 'Wbc')
					\ && (curpos[0] >= line('.') || (curpos[0] == line('.') && curpos[1] >= col('.')))
					\ && search('\V(', 'W')
					\ && searchpair('(', '', ')', 'W', skip)
					\ && search('\V{', 'W', line('.'))
					\ && (curpos[0] <= line('.') || (curpos[0] == line('.') && curpos[1] <= col('.')))
					let candidate.body = getcurpos()[1:2]
				else
					call cursor(curpos)
					if search('{', 'W', line('.'))
						let candidate.body = getcurpos()[1:2]
					else
						continue
					end
				end
			elseif searchpair('{', '', '}', 'Wb', skip, line('w0'))
				let candidate.body = getcurpos()[1:2]
			else
				break
			end

			call cursor(candidate.body)
			norm! %
			let candidate.end = getcurpos()[1:2]

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
			if search('\V)', 'Wb', line('.'))
				\ && searchpair('(', '', ')', 'Wb', skip)
				\ && search('\v(async\s+)?<function>', 'Wb', line('.'))
				\ && (curpos[0] != line('.') || curpos[0] == line('.') && curpos[1] >= col('.'))
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
		let before = strpart(getline(match.start[0]), 0, match.start[1]-1)
		let after = strpart(getline(match.end[0]), match.end[1])
		if before =~ '\v^\s*$' && after =~ '\v^\s*$' || a:leftside && before =~ '\v(:|\=)\s*\(?$'
			" Do linewise selection when the function is not an expression or the function is assigned
			" to something and a:leftseide is 1.
			" All empty lines after the function are also selected.
			call cursor(match.start)
			norm! 0
			norm! V
			call cursor(match.end)
			let next = nextnonblank(line('.')+1)
			if next
				call cursor(next-1, 1)
			end
		else
			call cursor(match.start)
			norm! v
			call cursor(match.end)
		end
	end

	call feedkeys('o')

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
			if objects#synat(line('.'), i) =~ 'String'
				if i == len(line) && empty(stack)
					let candidate.end = [line('.'), i]
					break
				end
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

		if candidate.end == [0, 0]
			break
		end

		call cursor(candidate.body)
		if search('\V\(\w\+\|)\)\s\*=>', 'Wb', line('.'))
			if getline('.')[col('.')-1] == ')'
				let skip = "objects#cursyn() =~ 'String'"
				call searchpair('(', '', ')', 'Wb', skip)
			end
			let candidate.start = getcurpos()[1:2]
		end

		if pos[1] >= candidate.start[1] && pos[1] <= candidate.end[1]
			let match = candidate
			break
		end

		call cursor(candidate.body)

	endw

	call cursor(pos)
	return match
endf
