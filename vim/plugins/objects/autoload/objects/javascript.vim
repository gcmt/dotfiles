
func! objects#javascript#function(inner)

	let curpos = getcurpos()[1:2]
	let skip = "objects#syntax() =~ '\\v^(String|Comment)$'"

	let start = [0, 0]
	let body_start = [0, 0]
	let end = [0, 0]

	for i in range(1, v:count1)
		while 1

			let start_candidate = [0, 0]

			if search('{', 'W', line('.')) || searchpair('{', '', '}', 'Wb', skip, line('w0'))
				let start_candidate = getcurpos()[1:2]
				let body_start = start_candidate
				norm! %
				let end = getcurpos()[1:2]
			else
				break
			end

			" detect arrow function
			call cursor(body_start)
			if search('\V)\s\*=>\s\*\%'.start_candidate[1].'c{', 'Wb', line('.')) &&
				\ searchpair('(', '', ')', 'Wb', skip)
				let start = getcurpos()[1:2]
				break
			end

			" detect arrow function with one parameter and no parentheses
			call cursor(body_start)
			if search('\V\w\+\s\*=>\s\*\%'.start_candidate[1].'c{', 'Wb', line('.'))
				let start = getcurpos()[1:2]
				break
			end

			" detect regular function
			call cursor(body_start)
			if search('\V)\s\*\%'.start_candidate[1].'c{', 'Wb', line('.')) &&
				\ searchpair('(', '', ')', 'Wb', skip) &&
				\ search('\v(async\s+)?<function>', 'Wb', line('.'))
				let start = getcurpos()[1:2]
				break
			end

			" detect short form and getter/setters
			call cursor(body_start)
			if search('\V)\s\*\%'.start_candidate[1].'c{', 'Wb', line('.')) &&
				\ searchpair('(', '', ')', 'Wb', skip) &&
				\ search('\v^\s*\zs((get|set)\s+)?[*A-Za-z$_][0-9A-Za-z$_]+\s*%'.col('.').'c\(', 'Wb', line('.')) &&
				\ getline('.') !~ '\v^\s*(for|while|if)>'
				let start = getcurpos()[1:2]
				break
			end

			call cursor(start_candidate)

		endw
	endfo

	if start == [0, 0]
		call cursor(curpos)
		return
	end

	if a:inner
		call cursor(body_start)
		norm! v
		call cursor(end)
	else
		call cursor(start)
		norm! v
		call cursor(end)
	end

endf
