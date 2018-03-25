
func! objects#javascript#function(inner)

	let curpos = getcurpos()[1:2]
	let skip = "objects#syntax() =~ '\\v^(String|Comment)$'"

	let start = [0, 0]
	let end = [0, 0]

	let start_block = [0, 0]
	let end_block = [0, 0]

	for i in range(1, v:count1)
		while 1

			if searchpair('{', '', '}', 'Wb', skip, line('w0'))
				let start = getcurpos()[1:2]
				let start_block = start
				norm! %
				let end = getcurpos()[1:2]
				let end_block = end
				call cursor(start)
			else
				break
			end

			if search('\V)\s\*=>\s\*\%'.start[1].'c{', 'Wb', line('.'), skip) &&
				\ searchpair('(', '', ')', 'Wb', skip)
				let start = getcurpos()[1:2]
				break
			end
			if search('\V)\s\*\%'.start[1].'c{', 'Wb', line('.'), skip) &&
				\ searchpair('(', '', ')', 'Wb', skip) &&
				\ search('\v(async\s+)?<function>', 'Wb', skip, line('.'))
				let start = getcurpos()[1:2]
				break
			end

			call cursor(start)

		endw
	endfo

	if start == [0, 0] && end == [0, 0]
		call cursor(curpos)
		return
	end

	if a:inner
		call cursor(start_block)
		norm! v
		call cursor(end_block)
	else
		call cursor(start)
		norm! v
		call cursor(end)
	end

endf
