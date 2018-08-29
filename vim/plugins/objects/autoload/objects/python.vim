

let s:default_options = {
	\ 'inner': 0,
	\ 'bounce': 1,
\ }


func! objects#python#function(options, visual, count)
	call s:select('def', s:options(a:options), a:visual, a:count)
endf


func! objects#python#class(options, visual, count)
	call s:select('class', s:options(a:options), a:visual, a:count)
endf


func! s:options(options)
	let globals = get(g:objects_options, 'python', {})
	return objects#merge_dicts(s:default_options, globals, a:options)
endf


func! s:empty_match()
	return {'start': 0, 'end': 0}
endf


func! s:get_selection()
	return { 'start': line("'<'"), 'end': line("'>") }
endf


func! s:select(kw, options, visual, count)

	let curpos = getcurpos()[1:2]
	let wanted = a:kw == 'class' ? 'class>' : 'def>|async def>'
	let match = s:empty_match()
	let sel = s:get_selection()

	" Based on the direction we keep either match.start or match.end pinned.
	let direction = 'down'
	if a:visual && sel.start != sel.end
		let match.start = sel.start
		let match.end = sel.end
		if curpos[0] == sel.end
			let direction = 'down'
		end
		if curpos[0] == sel.start
			let direction = 'up'
		end
	end

	for i in range(1, a:count)

		let candidate = s:empty_match()

		" Search for the definition start
		" --------------------------------------------------------------------

		if direction == 'down'

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

		if direction == 'down'
			let candidate.end = s:find_block_end(candidate.start)
		end

		" Find the first non-blank line so that we can reliably compare indent
		" levels. match.start can be an empty line when, for example, we are
		" extending a selection in the upper direction.
		let real_match_start = match.start
		if match.start != 0
			for k in range(match.start, line('$'))
				if !objects#emptyline(k)
					let real_match_start = k
					break
				end
			endfo
		end
		if !candidate.start && !candidate.end
			\ || match.start != 0 && indent(candidate.start) != indent(real_match_start)
			" The inendtation check makes sure we only select consecutive
			" definitions with the same indentation level.
			break
		end

		if direction == 'down'
			let match.start = match.start ? match.start : candidate.start
			let match.end = candidate.end
			call cursor(match.end, 1)
		else
			let match.start = candidate.start
			let match.end = match.end ? match.end : candidate.end
			call cursor(match.start, 1)
		end

	endfo

	call cursor(curpos)
	call s:do_selection(match, a:options, a:visual, direction)

endf


func! s:do_selection(match, options, visual, direction)

	if !a:match.start && !a:match.end
		return
	end

	if a:options.inner
		call cursor(a:match.start, 1)
		norm! V
		call cursor(a:match.end, len(getline(a:match.end)))
		call search('\v\S', 'Wbc')
	else
		call cursor(a:match.start, 1)
		if a:direction == 'up' || a:match.end == line('$') && a:options.bounce
			call cursor(prevnonblank(line('.')-1)+1, 1)
		end
		norm! V
		if a:match.end == line('$')
			call cursor(a:match.end, len(getline(a:match.end)))
		else
			let end = nextnonblank(a:match.end+1)
			call cursor(end-1, len(getline(end-1)))
		end
	end

	if a:visual && (a:direction == 'up' || a:match.end == line('$') && a:options.bounce)
		call feedkeys('o')
	end

endf


" s:find_block_end({start:number}[, {whitelist:list}]) -> number
" Find the block end of the block starting at line {start}.
" {whitelist} contains a list of keywords to be ignored (that is, they don't set
" the end of the block) when encountered at the same indent level of the line
" {start}.
func! s:find_block_end(start, ...)
	let whitelist = a:0 && type(a:1) == v:t_list ? '('.join(a:1, '|').')>' : ''
	let indent = indent(a:start)
	for i in range(a:start, line('$'))
		if !objects#emptyline(i) && indent(i) == indent
			continue
		end
		for k in range(i, line('$'))
			if k == line('$')
				return k
			end
			if objects#emptyline(k)
				continue
			end
			if indent(k) < indent
				\ || indent(k) == indent
				\ && (empty(whitelist) || getline(k) !~ '\v^\s{'.indent.'}'.whitelist)
				return prevnonblank(k-1)
			end
		endfo
	endfo
	return 0
endf
