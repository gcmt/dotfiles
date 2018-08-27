

let s:default_options = {
	\ 'inner': 0,
\ }


func! s:options(options)
	let merged = copy(s:default_options)
	call extend(merged, get(g:objects_options, 'python', {}))
	call extend(merged, a:options)
	return merged
endf


func! objects#python#function(...)
	let options = s:options(a:0 && type(a:1) == v:t_dict ? a:1 : {})
	call s:select('def', options, v:count1)
endf


func! objects#python#class(...)
	let options = s:options(a:0 && type(a:1) == v:t_dict ? a:1 : {})
	call s:select('class', options, v:count1)
endf


func! s:select(kw, options, count)

	let curpos = getcurpos()[1:2]
	let wanted = a:kw == 'class' ? 'class>' : 'def>|async def>'

	" Check whether or not we need to extend the current selection
	" This makes sure we can use counts to select consecutive definition blocks,
	" just like with paragraphs. Eg. v2af
	" --------------------------------------------------------------------

	norm! gv

	let extend_selection = 0
	let sel_start = getpos("'<")[1]
	let sel_end = getpos("'>")[1]

	if sel_start != sel_end
		let curpos = [sel_end, 1]
		let extend_selection = 1
	end

	exec "norm! \<esc>"

	" Search for the definition start
	" --------------------------------------------------------------------

	let start = 0
	let indent = -1

	" Check for a definition in the current indent block
	let linenr = curpos[0]
	if objects#emptyline(linenr) && !objects#emptyline(linenr+1)
		let linenr += 1
	end
	if getline(linenr) =~ '\v^\s*(\@|#|'.wanted.')'
		for i in range(linenr, line('$'))
			if objects#emptyline(i) || indent(i) != indent(linenr)
				break
			end
			if getline(i) =~ '\v^\s*('.wanted.')'
				let start = i
				break
			end
		endfo
	end

	" Search for a definition on the current line and backwards
	let candidate = start ? start : prevnonblank(curpos[0])
	let indent = indent(candidate)
	while indent >= 0
		if getline(candidate) =~ '\v^\s*('.wanted.')'
			" Check for decorators or comments to include in the selection
			for i in range(candidate, 0, -1)
				if i == 0 || getline(i-1) !~ '\v^\s{'.indent.'}(\@|#)'
					let start = i
					break
				end
			endfo
			break
		end
		let indent -= &shiftwidth
		let candidate = searchpos('\v^\s{'.indent.'}\w', 'Wb')[0]
	endw

	if start == 0
		call cursor(curpos)
		return
	end

	" Search for the definition end
	" --------------------------------------------------------------------

	let end = 0
	let indent = indent(start)
	for i in range(start, line('$'))
		if objects#emptyline(i) || indent(i) != indent
			for k in range(i, line('$'))
				if k == line('$')
					let end = k
					break
				end
				if !objects#emptyline(k) && indent(k) <= indent
					let end = k-1
					break
				end
			endfo
			break
		end
	endfo

	if end == 0
		call cursor(curpos)
		return
	end

	" Do selection
	" --------------------------------------------------------------------

	if a:options.inner
		if extend_selection
			call cursor(sel_start, 1)
		else
			call cursor(start, 1)
		end
		norm! V
		call cursor(end, len(getline(end)))
		call search('\v\S', 'Wbc')
	else
		if extend_selection
			call cursor(sel_start, 1)
		else
			call cursor(start, 1)
		end
		if end == line('$')
			call cursor(prevnonblank(line('.')-1)+1, 1)
		end
		norm! V
		call cursor(end, len(getline(end)))
	end

	" --------------------------------------------------------------------

	if end != line('$') && a:count-1 > 0
		call s:select(a:kw, a:options, a:count-1)
	else
		" Move cursor at the start of the selection
		call feedkeys("o")
	end

endf
