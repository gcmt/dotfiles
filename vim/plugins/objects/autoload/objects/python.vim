
func! objects#python#function(inner, outermost_def)
	call s:select('def', a:inner, a:outermost_def)
endf

func! objects#python#class(inner, outermost_def)
	call s:select('class', a:inner, a:outermost_def)
endf

func! s:select(type, inner, outermost_def)

	let curpos = getcurpos()[1:2]

	if getline(curpos[0]) =~ '\v^\s*'.a:type.'>'
		let start = searchpos('\v^\s*'.a:type.'>', 'Wbc')
	else
		let indent = indent(prevnonblank(curpos[0]))
		let start = searchpos('\v^\s{,'.max([indent-4, 0]).'}'.a:type.'>', 'Wbc')
	end
	if start == [0, 0]
		return
	end

	" select the outermost definition of the same type
	if a:outermost_def
		let indent = indent(start[0])
		while 1
			if indent == 0
				break
			end
			let indent -= 4
			let candidate = searchpos('\v^\s{'.indent.'}(class|def)>', 'Wb')
			let type = a:type == 'class' ? 'def' : 'class'
			if candidate == [0, 0] || getline(candidate[0]) =~ '\v^\s*'.type.'>'
				break
			end
			let start = candidate
		endw
		call cursor(curpos)
	end

	let indent = indent(start[0])
	let end = searchpos('\v(\n\ze^\s{,'.indent.'}\S|\S%$)', 'Wn')
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
		if end[0] == line('$')
			call cursor(prevnonblank(line('.')-1)+1, 1)
		end
		norm! V
		call cursor(end)
	end

endf
