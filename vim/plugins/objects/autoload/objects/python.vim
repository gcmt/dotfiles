

let s:default_options = {
	\ 'inner': 0,
	\ 'bounce': 1,
	\ 'comments': 1,
\ }


" API
" ----------------------------------------------------------------------------

func! objects#python#def(options, visual, count)
	call s:select('def', s:options(a:options), a:visual, a:count)
endf

func! objects#python#class(options, visual, count)
	call s:select('class', s:options(a:options), a:visual, a:count)
endf

func! objects#python#if(options, visual, count)
	call s:select('if', s:options(a:options), a:visual, a:count)
endf

func! objects#python#for(options, visual, count)
	call s:select('for', s:options(a:options), a:visual, a:count)
endf

func! objects#python#with(options, visual, count)
	call s:select('with', s:options(a:options), a:visual, a:count)
endf

func! objects#python#try(options, visual, count)
	call s:select('try', s:options(a:options), a:visual, a:count)
endf

" ----


let s:groups = {
	\ 'if': ['else', 'elif'],
	\ 'try': ['except', 'else', 'finally'],
	\ 'for': ['else'],
\ }


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

	" Regex pattern for matching comments and/or decorators just above
	" the target construct
	let include = a:kw =~ '\v^(class|def)$' ? ['\@'] : []
	let include += a:options.comments ? ['#'] : []
	let include = join(include, '|')

	let kw = a:kw == 'def' ? '(async\s+)?def>' : a:kw.'>'

	let curpos = getcurpos()[1:2]
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

		if direction == 'down'

			" Check for a definition in the current indent block
			let linenr = line('.')
			if objects#emptyline(linenr) && !objects#emptyline(linenr+1)
				let linenr += 1
			end
			if !empty(include) && getline(linenr) =~ '\v^\s*('.include.'|'.kw.')'
				for k in range(linenr, line('$'))
					if objects#emptyline(k) || indent(k) != indent(linenr)
						break
					end
					if getline(k) =~ '\v^\s*'.kw
						let candidate.start = k
						break
					end
					if getline(k) !~ '\v^\s*('.include.')'
						break
					end
				endfo
			end

		end

		" Search for a definition on the current line and backwards
		let start = candidate.start ? candidate.start : prevnonblank(line('.'))
		let indent = indent(start)
		while indent >= 0
			let related = get(s:groups, a:kw, [])
			if !empty(related) && getline(start) =~ '\v^\s*('.join(related, '|').')>'
				let start = searchpos('\v^\s{'.indent.'}\S', 'Wb')[0]
				continue
			end
			if getline(start) =~ '\v^\s*'.kw
				" Check for decorators or comments to include in the selection
				for k in range(start, 0, -1)
					if k == 0 || empty(include) || getline(k-1) !~ '\v^\s{'.indent.'}('.include.')'
						let candidate.start = k
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
			let candidate.end = s:find_block_end(a:kw, candidate.start)
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
			let end = nextnonblank(match.end+1)
			call cursor(end ? end-1 : match.end, 1)
		else
			let match.start = candidate.start
			let match.end = match.end ? match.end : candidate.end
			let start = prevnonblank(match.start-1)
			call cursor(start ? start+1 : match.start, 1)
		end

	endfo

	call cursor(curpos)
	call s:do_selection(match, a:kw, a:options, a:visual, direction)

endf


func! s:do_selection(match, kw, options, visual, direction)

	if !a:match.start && !a:match.end
		return
	end

	if a:options.inner
		call cursor(a:match.start, 1)
		norm! V
		call cursor(a:match.end, len(getline(a:match.end)))
	else
		call cursor(a:match.start, 1)
		if a:direction == 'up' || a:match.end == line('$') && a:options.bounce
			call cursor(prevnonblank(line('.')-1)+1, 1)
		end
		norm! V
		if a:direction == 'down'
			let end = nextnonblank(a:match.end+1)
			if a:kw !~ '\v^(def|class)$'
				\ && getline(end) =~ '\v^\s*((async\s+)?def|class|\@\w+)>'
				" I the next line after the match is a class or function definition,
				" don't select trailing empty lines (even if a:options.inner == 0)
				call cursor(a:match.end, len(getline(a:match.end)))
			else
				let end = end ? end-1 : a:match.end
				call cursor(end, len(getline(end)))
			end
		else
			call cursor(a:match.end, len(getline(a:match.end)))
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
func! s:find_block_end(kw, start)

	let whitelist = get(s:groups, a:kw, [])
	let indent = indent(a:start)

	let i = a:start
	while i <= line('$')

		let i += 1

		if !objects#emptyline(i) && indent(i) == indent
			continue
		end

		let k = i
		while k <= line('$')

			if k == line('$')
				return k
			end

			if objects#emptyline(k)
				let k += 1
				continue
			end

			if getline(k) =~ '\v^\s{'.indent.'}#'
				let j = k
				while j <= line('$')
					if getline(j) =~ '\v^\s{'.indent.'}#'
						let j += 1
						continue
					end
					if getline(j) =~ '\v^\s{'.indent.'}('.join(whitelist, '|').')>'
						let k = j
						break
					end
					break
				endw
			end

			if indent(k) < indent
				\ || indent(k) == indent
				\ && (empty(whitelist) || getline(k) !~ '\v^\s{'.indent.'}('.join(whitelist, '|').')>')
				return prevnonblank(k-1)
			end

			let k += 1
		endw

	endw

	return 0
endf
