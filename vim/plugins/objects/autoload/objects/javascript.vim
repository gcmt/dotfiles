

let g:objects_javascript_exclude_braces =
	\ get(g:, 'objects_javascript_exclude_braces', 1)


func! objects#javascript#class(only_body, include_assignment)
	call s:select('class', a:only_body, a:include_assignment)
endf


func! objects#javascript#function(only_body, include_assignment)
	call s:select('function', a:only_body, a:include_assignment)
endf


func! s:empty_match()
	return {"sign_start": [0, 0], "body_start": [0, 0], "body_end": [0, 0]}
endf


func! s:select(wanted, only_body, include_assignment)

	let curpos = getcurpos()[1:2]
	let skip = "objects#synat('.') =~ '\\v^(String|Comment)$'"
	let match = s:empty_match()

	for i in range(1, v:count1)

		let k = 0
		let candidate = s:empty_match()

		while 1

			let k += 1

			if i == 1 && k == 1

				if a:wanted == 'function'
					let candidate = s:detect_inline_arrow_function()
					if candidate.sign_start != [0, 0]
						break
					end
				end

				" Search the start of the function body when the cursor is inside
				" the function signature
				if a:wanted == 'function'
					\ && search('\v(<export\s+(default\s+)?)?(<async\s+)?<function>', 'Wbc')
					\ && (curpos[0] >= line('.') || (curpos[0] == line('.') && curpos[1] >= col('.')))
					\ && search('\V(', 'W')
					\ && searchpair('(', '', ')', 'W', skip)
					\ && search('\V{', 'W', line('.'))
					\ && (curpos[0] <= line('.') || (curpos[0] == line('.') && curpos[1] <= col('.')))
					let candidate.body_start = getcurpos()[1:2]
				else
					call cursor(curpos)
					if search('{', 'W', line('.'))
						let candidate.body_start = getcurpos()[1:2]
					else
						continue
					end
				end

			elseif searchpair('{', '', '}', 'Wb', skip)

				let candidate.body_start = getcurpos()[1:2]

			else
				break
			end

			" Find the end of the function/class body
			call cursor(candidate.body_start)
			keepj norm! %
			let candidate.body_end = getcurpos()[1:2]

			if a:wanted == 'class'

				" Find the class start
				call cursor(candidate.body_start)
				if search('\v(<export\s+(default\s+)?)?<class>', 'Wb', line('.'))
					\ && objects#synat('.') !~ 'String'
					\ && (curpos[0] != line('.') || curpos[0] == line('.') && curpos[1] >= col('.'))
					let candidate.sign_start = getcurpos()[1:2]
					break
				end

			elseif a:wanted == 'function'

				" Find signature start of arrow functions
				call cursor(candidate.body_start)
				if (search('\V\w\+\s\*=>', 'Wb', line('.'))
					\ || search('\V)\s\*=>', 'Wb', line('.')) && searchpair('(', '', ')', 'Wb', skip))
					\ && (curpos[0] != line('.') || curpos[0] == line('.') && curpos[1] >= col('.'))
					let candidate.sign_start = getcurpos()[1:2]
					break
				end

				" Find signature start of regular functions
				call cursor(candidate.body_start)
				if search('\V)', 'Wb', line('.'))
					\ && searchpair('(', '', ')', 'Wb', skip)
					\ && search('\v(<export\s+(default\s+)?)?(<async\s+)?<function>', 'Wb', line('.'))
					\ && (curpos[0] != line('.') || curpos[0] == line('.') && curpos[1] >= col('.'))
					let candidate.sign_start = getcurpos()[1:2]
					break
				end

				" Find signature of shorthand method definitions
				call cursor(candidate.body_start)
				if search('\V)', 'Wb', line('.'))
					\ && searchpair('(', '', ')', 'Wb', skip)
					\ && search('\v^\s*\zs((get|set|static)\s+)?[*A-Za-z$_][0-9A-Za-z$_]+\s*', 'Wb', line('.'))
					\ && getline('.') !~ '\v^\s*(for|while|if|switch|return)>'
					\ && (curpos[0] != line('.') || curpos[0] == line('.') && curpos[1] >= col('.'))
					let candidate.sign_start = getcurpos()[1:2]
					break
				end

				" Detect computed properties names
				call cursor(candidate.body_start)
				if search('\V)', 'Wb', line('.'))
					\ && searchpair('(', '', ')', 'Wb', skip)
					\ && search('\v^\s*\zs((get|set|static)\s+)?\[.*\]\s*', 'Wb', line('.'))
					\ && (curpos[0] != line('.') || curpos[0] == line('.') && curpos[1] >= col('.'))
					let candidate.sign_start = getcurpos()[1:2]
					break
				end

			else
				throw "Can only select classes or functions"
			end

			call cursor(candidate.body_start)

		endw

		if candidate.sign_start == [0, 0]
			break
		end

		let match = candidate
		call cursor(match.sign_start)

	endfo

	call cursor(curpos)
	call s:do_selection(match, a:only_body, a:include_assignment)

endf


func! s:do_selection(match, only_body, include_assignment)

	if a:match.sign_start == [0, 0]
		return
	end

	if a:only_body

		call cursor(a:match.body_start)
		if getline('.')[col('.')-1] == '{'
			\ && g:objects_javascript_exclude_braces
			call search('\S', 'W')
		end

		norm! v

		call cursor(a:match.body_end)
		if getline('.')[col('.')-1] == '}'
			\ && g:objects_javascript_exclude_braces
			call search('\S', 'Wb')
		end

	else

		let before = strpart(getline(a:match.sign_start[0]), 0, a:match.sign_start[1]-1)
		let after = strpart(getline(a:match.body_end[0]), a:match.body_end[1])
		if before =~ '\v^\s*$' && after =~ '\v^\s*$'
			\ || a:include_assignment && before =~ '\v(:|\=)\s*$'
			" Do linewise selection when the function is not an expression or the
			" function is assigned to something and a:include_assignment is 1. All
			" empty lines after the function are also selected.
			call cursor(a:match.sign_start)
			norm! 0
			norm! V
			call cursor(a:match.body_end)
			let next = nextnonblank(line('.')+1)
			if next
				call cursor(next-1, 1)
			end
		else
			call cursor(a:match.sign_start)
			norm! v
			call cursor(a:match.body_end)
		end

	end

	" move the cursor to the start of the selection
	call feedkeys('o')

endf


func! s:detect_inline_arrow_function()

	let pos = getcurpos()[1:2]
	let match = s:empty_match()

	norm! 0
	while search('\V=>\s\*\S', 'e', line('.'))

		if objects#synat('.') =~ 'String'
			continue
		end

		let candidate = s:empty_match()
		let candidate.body_start = getcurpos()[1:2]

		let stack = []
		let pairs = {'(': ')', '[': ']', '{': '}'}
		let line = getline('.')

		for i in range(col('.'), col('$')-1)
			let char = line[i-1]
			if objects#synat(line('.'), i) =~ 'String'
				if i == len(line) && empty(stack)
					let candidate.body_end = [line('.'), i]
					break
				end
				continue
			end
			if char =~ '\v(,|;|\)|\]|})' && empty(stack)
				let candidate.body_end = [line('.'), i-1]
				break
			end
			if has_key(pairs, char)
				call add(stack, char)
			elseif get(pairs, get(stack, -1, ''), '') == char
				call remove(stack, -1)
			end
			if i == len(line) && empty(stack)
				let candidate.body_end = [line('.'), i]
				break
			end
		endfo

		if candidate.body_end == [0, 0]
			break
		end

		call cursor(candidate.body_start)
		if search('\V\(\w\+\|)\)\s\*=>', 'Wb', line('.'))
			if getline('.')[col('.')-1] == ')'
				let skip = "objects#synat('.') =~ 'String'"
				call searchpair('(', '', ')', 'Wb', skip)
			end
			let candidate.sign_start = getcurpos()[1:2]
		end

		if pos[1] >= candidate.sign_start[1] && pos[1] <= candidate.body_end[1]
			let match = candidate
			break
		end

		call cursor(candidate.body_start)

	endw

	call cursor(pos)
	return match
endf
