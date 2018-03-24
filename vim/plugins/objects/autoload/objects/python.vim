
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

	" start searching for a definition in the current block
	if getline(curpos[0]) =~ '\v^\s*$'
		let linenr = nextnonblank(curpos[0])
	else
		let linenr = curpos[0]
	end
	if linenr == curpos[0] || linenr == curpos[0]+1
		for i in range(linenr, line('$'))
			if s:emptyline(i) || indent(i) != indent(linenr)
				break
			end
			if getline(i) =~ '\v^\s*('.wanted.')'
				" definition found, now start searching backwards for the start
				for k in range(i, 0, -1)
					if k == 0 || s:emptyline(k-1) || indent(k-1) != indent(i)
						let start = [k, 1]
						break
					end
				endfo
			end
		endfo
	end

	" if no definition is found in the current block,
	" search backwards for a definition
	if start == [0, 0]
		let indent = indent(prevnonblank(curpos[0]))
		while indent > 0
			let indent -= &shiftwidth
			let candidate = searchpos('\v^\s{'.indent.'}\w', 'Wb')
			if candidate == [0, 0]
				continue
			end
			if getline(candidate[0]) =~ '\v^\s*('.wanted.')'
				let start = searchpos('\v(^$\n\zs(^\s*(\@|#|'.wanted.'))|%^)', 'Wbc')
				if !a:outermost
					break
				end
			end
		endw
	end

	" search for the end
	call cursor(start)
	let indent = indent(start[0])
	let end = searchpos('\v(^$\n\ze^\s{,'.indent.'}\S|\S%$)', 'W')

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
