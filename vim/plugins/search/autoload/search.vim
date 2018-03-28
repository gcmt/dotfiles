
let s:bufname = '__search__'

func! search#do(bang, args)

	if bufwinnr(s:bufname) != -1
		exec bufwinnr(s:bufname) . 'wincmd c'
	end

	if empty(a:args) && !empty(get(g:, 'search_last_args', ''))
		let args = g:search_last_args
	else
		let args = a:args
		let g:search_last_args = a:args
	end

	let exclude_syn = []
	if !empty(a:bang)
		let exclude_syn = g:search_exclude_syn
	end

	let matches = s:search(args, exclude_syn)
	if len(matches) == 0
		return s:err("Nothing found")
	end

	exec 'sil keepa botright 1new' s:bufname
	setl filetype=search buftype=nofile bufhidden=hide nobuflisted
	setl noundofile nobackup noswapfile nospell
	setl nowrap nonumber norelativenumber nolist textwidth=0
	setl cursorline nocursorcolumn colorcolumn=0 laststatus=2
	call setwinvar(0, '&stl', " /" . args . "/%=search ")
	let b:search = {'table': {}, 'pattern': args}

	call s:render(matches)

endf

func! s:search(pattern, exclude_syn)

	let matches = []
	for i in range(1, line('$'))
		let match = matchstrpos(getline(i), a:pattern)
		if empty(match[0])
			continue
		end
		if !empty(a:exclude_syn) && index(a:exclude_syn, s:synat(i, match[1]+1)) != -1
			continue
		end
		call add(matches, [i, match[1]+1, bufnr('%')])
	endfo

	return matches

endf

func! s:render(matches)

	setl ma nolist
	sil %delete _

	let b:search.table = {}
	let width = len(max(map(copy(a:matches), 'v:val[0]')))
	for i in range(len(a:matches))
		let m = a:matches[i]
		let b:search.table[i+1] = m
		let line = printf("%".width."s %s", m[0], getbufline(m[2], m[0])[0])
		call setline(i+1, line)
	endfor

	call s:do_highlight()
	call s:resize_window()
	call s:find_closest_match()
	setl noma

endf

func! s:find_closest_match()
	wincmd p
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
	call cursor(1, 1)
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
