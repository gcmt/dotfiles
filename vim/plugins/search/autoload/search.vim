
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
	call s:render(matches)

endf

func! s:search(pattern, exclude_syn)

	let matches = []
	let winsave = winsaveview()
	call cursor(1, 1)

	while 1
		let pos = searchpos(a:pattern, 'W')
		if pos == [0, 0]
			break
		end
		if index(a:exclude_syn, s:synat(pos[0], pos[1])) != -1
			continue
		end
		let prev = get(matches, -1, [0, 0, ''])
		if pos[0] == prev[0] && getline(pos[0]) == prev[2]
			continue
		end
		call add(matches, pos + [getline(pos[0])])
	endw

	call winrestview(winsave)
	return matches

endf

func! s:render(matches)

	setl ma nolist
	sil %delete _

	let b:search_table = {}
	let width = len(max(map(copy(a:matches), 'v:val[0]')))
	for i in range(len(a:matches))
		let b:search_table[i+1] = a:matches[i][:1]
		let line = printf("%".width."s %s", a:matches[i][0], a:matches[i][2])
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
	for [line, entry] in items(b:search_table)
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
	call matchadd('LineNr', '\v^\s*\d+')
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
