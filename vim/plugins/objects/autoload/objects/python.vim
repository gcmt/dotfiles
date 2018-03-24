
func! objects#python#function(inner, outermost)
	call s:select('def', a:inner, a:outermost, v:count1)
endf

func! objects#python#class(inner, outermost)
	call s:select('class', a:inner, a:outermost, v:count1)
endf

func! s:select(kw, inner, outermost, count)

	if a:count <= 0
		return
	end

	let curpos = getcurpos()[1:2]
	let wanted = a:kw == 'class' ? 'class>' : 'def>|async def>'

	norm! gv

	let extend_selection = 0
	let sel_start = getpos("'<")[1:2]
	let sel_end = getpos("'>")[1:2]

	if sel_start != sel_end
		let curpos = sel_end
		let extend_selection = 1
	end

	exec "norm! \<esc>"

	let start = [0, 0]
	let indent = -1

	let linenr = curpos[0]
	if s:emptyline(linenr) && !s:emptyline(linenr+1)
		let linenr += 1
	end
	for i in range(linenr, line('$'))
		if s:emptyline(i) || indent(i) != indent(linenr)
			break
		end
		if getline(i) =~ '\v^\s*('.wanted.')'
			let start = [i, 1]
			let indent = indent(i)
		end
	endfo

	if start == [0, 0]
		let prev = prevnonblank(curpos[0])
		let start = prev ? [prev, 1] : [0, 0]
		let indent = indent(prev)
	end

	" search backwards for a definition
	while indent >= 0
		if getline(start[0]) =~ '\v^\s*('.wanted.')'
			for i in range(start[0], 0, -1)
				if i == 0 || s:emptyline(i-1) || indent(i-1) != indent(start[0])
					let start = [i, 1]
					break
				end
			endfo
			if !a:outermost
				break
			end
		end
		let indent -= &shiftwidth
		if indent >= 0
			let start = searchpos('\v^\s{'.indent.'}\w', 'Wb')
		end
	endw

	if start == [0, 0]
		call cursor(curpos)
		return
	end

	" search for the end
	let end = [0, 0]
	let indent = indent(start[0])
	for i in range(start[0], line('$'))
		if s:emptyline(i) || indent(i) != indent
			for k in range(i, line('$'))
				if k == line('$')
					let end = [k, len(getline(k))]
					break
				end
				if !s:emptyline(k) && indent(k) == indent
					let end = [k-1, len(getline(k-1))]
					break
				end
			endfo
			break
		end
	endfo

	if end == [0, 0]
		call cursor(curpos)
		return
	end

	" do selection
	if a:inner
		if extend_selection
			call cursor(sel_start)
		else
			call cursor(start)
		end
		norm! V
		call cursor(end)
		call search('\v\S', 'Wbc')
	else
		if extend_selection
			call cursor(sel_start)
		else
			call cursor(start)
		end
		if end[0] == line('$')
			call cursor(prevnonblank(line('.')-1)+1, 1)
		end
		norm! V
		call cursor(end)
	end

	if end[0] != line('$')
		call s:select(a:kw, a:inner, a:outermost, a:count-1)
	end

endf

func! s:emptyline(line)
	let line = type(a:line) == v:t_number ? getline(a:line) : a:line
	return line =~ '\v^\s*$'
endf
