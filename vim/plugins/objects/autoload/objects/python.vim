
func! objects#python#function(inner)
	call s:select('def', a:inner)
endf

func! objects#python#class(inner)
	call s:select('class', a:inner)
endf

func! s:select(keyword, inner)

	let start = searchpos('\v^\s*'.a:keyword.'>', 'Wbnc')
	if start == [0, 0]
		return
	end

	let indent = len(matchstr(getline(start[0]), '\v^\s*'))
	let end = searchpos('\v(^\s{,'.indent.'}(class|def)|%$)', 'Wn')
	if end == [0, 0]
		return
	end

	if a:inner
		call cursor(start)
		norm! V
		call cursor(end)
		call search('\v\S', 'Wb')
	else
		call cursor(start)
		norm! V
		let end = end[0] == line('$') ? end : [end[0]-1, 1]
		call cursor(end)
	end

endf
