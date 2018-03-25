
func! objects#javascript#function(inner)

	let curpos = getcurpos()[1:2]
	let skip = "objects#syntax() =~ '\\v^(String|Comment)$'"

	let start = [0, 0]
	let start_body = [0, 0]
	let end = [0, 0]

	for i in range(1, v:count1)
		while 1

			let candidate_start = [0, 0]
			let candidate_end = [0, 0]

			if search('{', 'W', line('.')) || searchpair('{', '', '}', 'Wb', skip, line('w0'))
				let candidate_start = getcurpos()[1:2]
				let start_body = candidate_start
				norm! %
				let candidate_end = getcurpos()[1:2]
			else
				break
			end

			" detect arrow function
			call cursor(start_body)
			if search('\V)\s\*=>\s\*\%'.candidate_start[1].'c{', 'Wb', line('.')) &&
				\ searchpair('(', '', ')', 'Wb', skip)
				let start = getcurpos()[1:2]
				let end = candidate_end
				break
			end

			" detect arrow function with one parameter and no parentheses
			call cursor(start_body)
			if search('\V\w\+\s\*=>\s\*\%'.candidate_start[1].'c{', 'Wb', line('.'))
				let start = getcurpos()[1:2]
				let end = candidate_end
				break
			end

			" detect regular function
			call cursor(start_body)
			if search('\V)\s\*\%'.candidate_start[1].'c{', 'Wb', line('.')) &&
				\ searchpair('(', '', ')', 'Wb', skip) &&
				\ search('\v(async\s+)?<function>', 'Wb', line('.'))
				let start = getcurpos()[1:2]
				let end = candidate_end
				break
			end

			" detect short form and getter/setters
			call cursor(start_body)
			if search('\V)\s\*\%'.candidate_start[1].'c{', 'Wb', line('.')) &&
				\ searchpair('(', '', ')', 'Wb', skip) &&
				\ search('\v^\s*\zs((get|set)\s+)?[*A-Za-z$_][0-9A-Za-z$_]+\s*%'.col('.').'c\(', 'Wb', line('.')) &&
				\ getline('.') !~ '\v^\s*(for|while|if)>'
				let start = getcurpos()[1:2]
				let end = candidate_end
				break
			end

			call cursor(candidate_start)

		endw
	endfo

	if start == [0, 0] && end == [0, 0]
		call cursor(curpos)
		return
	end

	if a:inner
		call cursor(start_body)
		norm! v
		call cursor(end)
	else
		call cursor(start)
		norm! v
		call cursor(end)
	end

endf
