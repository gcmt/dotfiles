
let s:bufname = '__search__'

func! search#do(bang, pattern)

	if bufwinnr(s:bufname) != -1
		exec bufwinnr(s:bufname) . 'wincmd c'
	end

	if empty(a:pattern)
		if empty(g:search_history)
			return s:err("No previous searches")
		end
		let ctx = g:search_history[-1]
	else
		let exclude_syn = empty(a:bang) ? [] : g:search_exclude_syn
		let ctx = {'bufnr': bufnr('%'), 'pattern': a:pattern, 'exclude_syn': exclude_syn}
		if ctx != get(g:search_history, -1, {})
			call add(g:search_history, ctx)
		end
	end

	let matches = s:search(ctx)
	if len(matches) == 0
		return s:err("Nothing found")
	end

	exec 'sil keepa botright 1new' s:bufname
	setl filetype=search buftype=nofile bufhidden=hide nobuflisted
	setl noundofile nobackup noswapfile nospell
	setl nowrap nonumber norelativenumber nolist textwidth=0
	setl cursorline nocursorcolumn colorcolumn=0 laststatus=2
	let buf = join(split(fnamemodify(bufname(ctx.bufnr), ':p:~'), '/')[-1:], '/')
	call setwinvar(0, '&stl', " /" . ctx.pattern . "/ " . buf . "%=search ")
	let b:search = {'table': {}, 'ctx': ctx}

	call s:render(matches)

endf

func! s:search(ctx)

	let matches = []
	let lines = getbufline(a:ctx.bufnr, 1, '$')
	for i in range(0, len(lines)-1)
		let match = matchstrpos(lines[i], a:ctx.pattern)
		if empty(match[0])
			continue
		end
		if !empty(a:ctx.exclude_syn) && index(a:ctx.exclude_syn, s:synat(i+1, match[1]+1)) != -1
			continue
		end
		call add(matches, [i+1, match[1]+1])
	endfo

	return matches

endf

func! s:render(matches)

	syn clear
	setl ma nolist
	sil %delete _

	let b:search.table = {}
	let width = len(max(map(copy(a:matches), 'v:val[0]')))
	for i in range(len(a:matches))
		let m = a:matches[i]
		let b:search.table[i+1] = m
		let line = printf("%".width."s %s", m[0], getbufline(b:search.ctx.bufnr, m[0])[0])
		call setline(i+1, line)
	endfor

	call s:do_highlight()
	call s:resize_window()
	call s:find_closest_match()
	setl noma

endf

func! s:find_closest_match()
	call cursor(1, 1)
	let winnr = bufwinnr(b:search.ctx.bufnr)
	if winnr == -1
		return
	end
	exec winnr.'wincmd w'
	let curline = line('.')
	wincmd p
	let mindist = 99999
	let closest = line('.')
	for [line, entry] in items(b:search.table)
		let dist = abs(curline - entry[0])
		if dist < mindist
			let mindist = dist
			let closest = line
		end
	endfo
	call cursor(closest, 1)
endf

func! s:do_highlight()
	syn match LineNr /\v^\s*\d+/
endf

func! s:resize_window()
	let max = float2nr(&lines * g:search_max_winsize / 100)
	exec 'resize' min([line('$'), max])
endf

func! s:synat(line, col)
	return synIDattr(synIDtrans(synID(a:line, a:col, 0)), 'name')
endf

func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
