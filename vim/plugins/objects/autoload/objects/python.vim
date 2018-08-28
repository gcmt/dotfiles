

let s:default_options = {
	\ 'inner': 0,
	\ 'bounce': 1,
\ }


func! s:options(options)
	let merged = copy(s:default_options)
	call extend(merged, get(g:objects_options, 'python', {}))
	call extend(merged, a:options)
	return merged
endf


func! objects#python#function(options, visual)
	call s:select('def', s:options(a:options), a:visual)
endf


func! objects#python#class(options, visual)
	call s:select('class', s:options(a:options), a:visual)
endf


func! s:empty_match()
	return {'start': 0, 'end': 0}
endf


func! s:select(kw, options, visual)

	let curpos = getcurpos()[1:2]
	let wanted = a:kw == 'class' ? 'class>' : 'def>|async def>'
	let match = s:empty_match()

	for i in range(1, v:count1)

		let candidate = s:empty_match()

		" Search for the definition start
		" --------------------------------------------------------------------

		" Check for a definition in the current indent block
		let linenr = line('.')
		if objects#emptyline(linenr) && !objects#emptyline(linenr+1)
			let linenr += 1
		end
		if getline(linenr) =~ '\v^\s*(\@|#|'.wanted.')'
			for i in range(linenr, line('$'))
				if objects#emptyline(i) || indent(i) != indent(linenr)
					break
				end
				if getline(i) =~ '\v^\s*('.wanted.')'
					let candidate.start = i
					break
				end
			endfo
		end

		" Search for a definition on the current line and backwards
		let start = candidate.start ? candidate.start : prevnonblank(line('.'))
		let indent = indent(start)
		while indent >= 0
			if getline(start) =~ '\v^\s*('.wanted.')'
				" Check for decorators or comments to include in the selection
				for i in range(start, 0, -1)
					if i == 0 || getline(i-1) !~ '\v^\s{'.indent.'}(\@|#)'
						let candidate.start = i
						break
					end
				endfo
				break
			end
			let indent -= &shiftwidth
			let start = searchpos('\v^\s{'.indent.'}\S', 'Wb')[0]
		endw

		if candidate.start == 0
			call cursor(curpos)
			return
		end

		" Search for the definition end
		" --------------------------------------------------------------------

		let indent = indent(candidate.start)
		for i in range(candidate.start, line('$'))
			if objects#emptyline(i) || indent(i) != indent
				for k in range(i, line('$'))
					if k == line('$')
						let candidate.end = k
						break
					end
					if !objects#emptyline(k) && indent(k) <= indent
						let candidate.end = k-1
						break
					end
				endfo
				break
			end
		endfo

		if !candidate.start && !candidate.end
			\ || match.start != 0 && indent(candidate.start) != indent(match.start)
			" The inendtation check makes sure we only select consecutive
			" definitions with the same indentation level.
			break
		end

		let match.start = match.start ? match.start : candidate.start
		let match.end = candidate.end

		call cursor(match.end, 1)

	endfo

	call cursor(curpos)
	call s:do_selection(match, a:options, a:visual)

endf


func! s:do_selection(match, options, visual)

	if !a:match.start && !a:match.end
		return
	end

	if a:options.inner
		call cursor(a:match.end, len(getline(a:match.end)))
		call search('\v\S', 'Wbc')
		norm! V
		call cursor(a:match.start, 1)
	else
		call cursor(a:match.end, len(getline(a:match.end)))
		norm! V
		call cursor(a:match.start, 1)
		if a:match.end == line('$') && a:options.bounce
			call cursor(prevnonblank(line('.')-1)+1, 1)
		end
	end

	if a:visual
		call objects#adjust_view(a:match.start, a:match.end)
		call feedkeys('o')
	end

endf
