
let s:search = {}

let s:default_search_options = {
	\ 'exclude_syn': [],
	\ 'set_search_register': 1,
	\ 'add_to_search_history': 1,
\ }

let s:default_view_options = {
	\ 'show_line_numbers': 1,
	\ 'max_win_height': 50,
	\ 'goto_closest_match': 1,
\ }

" search#do({bufnr:number}, {pattern:string}, {search_bufname:string}, {search_options:dict}, {view_options:dict}) -> 0
" Search for {pattern} in buffer {bufnr} and display search results in a buffer
" in order to easily jump to them.
" To create multiple search buffers use different {search_bufname}s.
func! search#do(bufnr, pattern, search_bufname, search_options, view_options)

	if !bufexists(a:bufnr)
		return s:err(printf("Buffer %s does not exist", self.bufnr))
	end

	if empty(a:pattern)
		if bufexists(a:search_bufname)
			let s = getbufvar(bufnr(a:search_bufname), 'search').s
			if !s.do()
				call s:err("Nothing found")
			else
				exec 'sil keepa botright 1new' a:search_bufname
				call s.render()
			end
		else
			call s:err("No previous searches")
		end
		return
	end

	let s = s:search.new(a:bufnr, a:pattern, a:search_options, a:view_options)
	if !s.do()
		return s:err("Nothing found")
	end

	exec 'sil keepa botright 1new' a:search_bufname
	setl filetype=search buftype=nofile bufhidden=hide nobuflisted
	setl noundofile nobackup noswapfile nospell
	setl nowrap nonumber norelativenumber nolist textwidth=0
	setl cursorline nocursorcolumn colorcolumn=0

	let b:search = {'s': s}
	call s.render()

	set hlsearch
	autocmd WinLeave <buffer> set nohlsearch

endf

" s:search.new({bufnr:number}, {pattern:string}, {search_options:dict}, {view_options:dict}) -> dict
" Create a new search object. The actual search is done with 's:search.do()'.
func! s:search.new(bufnr, pattern, search_options, view_options)
	let s = copy(s:search)
	let s.matches = []
	let s.bufnr = a:bufnr
	let s.pattern = a:pattern
	let s.options = extend(a:search_options, s:default_search_options, 'keep')
	let s.view_options = extend(a:view_options, s:default_view_options, 'keep')
	return s
endf

" s:search.set_options({options:dict}) -> 0
" Update search options.
func! s:search.set_options(options)
	let self.options = extend(self.options, a:options, 'force')
endf

" s:search.set_view_options({options:dict}) -> 0
" Update search view options.
func! s:search.set_view_options(options)
	let self.view_options = extend(self.view_options, a:options, 'force')
endf

" s:search.do() -> number
" Search for 'self.pattern' in buffer 'self.bufnr'.
" Filtering by syntax require the current buffer to be equal to 'self.bufnr'.
" A number is returned to indicate success (1) or failure (0).
func! s:search.do()
	let self.matches = []
	let lines = getbufline(self.bufnr, 1, '$')
	let exclude_syn = {}
	if bufnr('%') == self.bufnr
		let exclude_syn = s:list2dict(self.options.exclude_syn)
	else
		call s:err(printf("Search: current buffer is %s, filtering by syntax not available in buffer %s", bufnr('%'), self.bufnr))
	end
	for i in range(0, len(lines)-1)
		let match = matchstrpos(lines[i], self.pattern)
		if empty(match[0])
			continue
		end
		if !empty(exclude_syn) && has_key(exclude_syn, s:synat(i+1, match[1]+1))
			continue
		end
		call add(self.matches, [i+1, match[1]+1])
	endfo
	if empty(self.matches)
		return 0
	end
	if self.options.set_search_register
		let @/ = self.pattern
	end
	if self.options.add_to_search_history
		call histadd('/', self.pattern)
	end
	return 1
endf

" s:search.render([{view_options:dict}]) -> 0
" Render search results in the current buffer.
" If an argument {view_options} is given, then view options are updated with
" those values before rendering search results. This is the equivalent of
" calling 's:search.set_view_options(..)' just before 's:search.render()'.
func! s:search.render(...)

	if a:0 > 0 && type(a:1) == v:t_dict
		call self.set_view_options(a:1)
	end

	syn clear
	setl modifiable nolist
	sil %delete _

	let b:search.table = {}
	let width = len(max(map(copy(self.matches), 'v:val[0]')))
	for i in range(len(self.matches))
		let m = self.matches[i]
		let b:search.table[i+1] = m
		let num = printf("%".width."s ", m[0])
		let line = self.view_options.show_line_numbers ? num : ""
		let line .= getbufline(self.bufnr, m[0])[0]
		call setline(i+1, line)
	endfor

	syn match LineNr /\v^\s*\d+/

	call self.resize_window()
	call self.set_statusline()

	if self.view_options.goto_closest_match
		call self.goto_closest_match()
	end

	setl nomodifiable

endf

" s:search.goto_closest_match() -> 0
" Move the cursor to the match closest to the current cursor position
" in the searched buffer.
func! s:search.goto_closest_match()
	call cursor(1, 1)
	if !s:goto_bufwinnr(self.bufnr)
		return
	end
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

" s:search.set_statusline() -> 0
" Set the statusline with the current search info.
func! s:search.set_statusline()
	let bufname = join(split(fnamemodify(bufname(self.bufnr), ':p:~'), '/')[-1:], '/')
	call setwinvar(0, '&stl', ' search /' . self.pattern . '/ ' . bufname)
endf

" s:search.resize_window() -> 0
" Resize the current window to be at most 'self.view_options.max_win_height'%
" of the Vim window height.
func! s:search.resize_window()
	let max = float2nr(&lines * self.view_options.max_win_height / 100)
	exec 'resize' min([line('$'), max])
endf

" s:synat({line:number}, {col:number}) -> string
" Return the syntax group at the given position.
func! s:synat(line, col)
	return synIDattr(synIDtrans(synID(a:line, a:col, 0)), 'name')
endf

" s:list2dict({list:list}[, {fn:funcref}]) -> dict
" Construct a dictionary from a list.
" If a function {fn} is given, then to every dictionary key 'item' will
" be associated the value returned from fn(item). If {fn} is not given, the
" value 1 is used instead.
func! s:list2dict(list, ...)
	let dict = {}
	let Fn = a:0 > 0 && type(a:1) == t:v_func ? a:1 : {-> 1}
	for item in a:list
		if !has_key(dict, item)
			let dict[item] = Fn(item)
		end
	endfo
	return dict
endf

" s:goto_bufwinnr({bufnr:number}) -> number
" Go to the first window that contains the buffer {bufnr}.
func! s:goto_bufwinnr(bufnr)
	let winnr = bufwinnr(a:bufnr)
	if winnr == -1
		return 0
	end
	exec winnr.'wincmd w'
	return 1
endf

" s:err({msg:string}) -> 0
" Display a simple error message.
func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
