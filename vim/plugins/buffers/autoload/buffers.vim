
let s:bufname = '__buffers__'


" s:id() -> number
" Returns a new id everytime it's called
let s:_id = 0
func! s:id()
	let s:_id += 1
	return s:_id
endf


" buffers#view({all}) -> 0
" View the buffers list in a window.
"
" Args:
"   - all (bool): whether or not to also display unlisted buffers
"
func! buffers#view(all) abort

	if bufwinnr(s:bufname) != -1
		return
	end

	if len(s:get_buffers(a:all)) == 1
		return s:err("No more buffers")
	end

	let bufnr = bufnr(s:bufname, 1)
	call bufload(bufnr)

	call setbufvar(bufnr, '&filetype', 'buffers')
	call setbufvar(bufnr, '&buftype', 'nofile')
	call setbufvar(bufnr, '&bufhidden', 'hide')
	call setbufvar(bufnr, '&buflisted', 0)

	let [table, matches] = buffers#render(bufnr, a:all)

	call setbufvar(bufnr, "buffers", {
		\ 'table': table,
		\ 'current_bufnr': bufnr('%'),
		\ 'current_winnr': winnr(),
		\ 'all': a:all,
		\ 'matches': matches
	\})

	exec 'sil keepj keepa botright 1new' s:bufname
	let winid = bufwinid(s:bufname)

	call setwinvar(winid, '&cursorline', 1)
	call setwinvar(winid, '&cursorcolumn', 0)
	call setwinvar(winid, '&colorcolumn', 0)
	call setwinvar(winid, '&wrap', 0)
	call setwinvar(winid, '&number', 0)
	call setwinvar(winid, '&relativenumber', 0)
	call setwinvar(winid, '&list', 0)
	call setwinvar(winid, '&textwidth', 0)
	call setwinvar(winid, '&undofile', 0)
	call setwinvar(winid, '&backup', 0)
	call setwinvar(winid, '&swapfile', 0)
	call setwinvar(winid, '&spell', 0)

	" hide statusbar
	exec 'au BufHidden <buffer='.bufnr.'> let &laststatus = ' getwinvar(winid, "&laststatus")
	call setwinvar(winid, '&laststatus', '0')

	call s:resize_window(g:buffers_max_height)

	call setmatches(matches)

	" push the last line to the bottom in order to not have any empty space
	call cursor(1, line('$'))
	norm! zb

	" position the cursor to the current buffer
	for [line, bufnr] in items(b:buffers.table)
		if bufnr == b:buffers.current_bufnr
			call cursor(line, 1)
			break
		end
	endfor

	" unless at the very bottom, center the cursor position
	if line('.') < (line('$')-winheight(0)/2)
		norm! zz
	end

endf


" s:buffers#render({bufnr}, {all}) -> [{table}, {matches}]
" Render the buffers list in the given buffer.
"
" Args:
"  - bufnr (number): the buffer number where buffers need to be rendered
"  - all (bool): whether or not to also display unlisted buffers
"
" Returns:
"   - table (dict): a dictionary that maps buffer numbers to buffer lines
"   - matches (list): a list of matches to be set with `setmatches()`
"
func! buffers#render(bufnr, all)

	let buffers = s:get_buffers(a:all)

	call setbufvar(a:bufnr, "&modifiable", 1)
	sil! call deletebufline(a:bufnr, 1, "$")

	let tails = {}
	for bufnr in buffers
		let tail = fnamemodify(bufname(bufnr), ':t')
		let tails[tail] = get(tails, tail) + 1
	endfo

	let table = {}
	let matches = []

	let i = 1
	for b in buffers

		let table[i] = b

		let is_terminal = getbufvar(b, '&bt') == 'terminal'
		let is_modified = getbufvar(b, '&mod')

		let name = bufname(b)

		if empty(name)
			let name = b
			let detail = '[unnamed buffer]'
		elseif is_terminal
			let detail = '[terminal]'
		else
			let detail = s:prettify_path(fnamemodify(name, ':p'))
			let name =  fnamemodify(detail, ':t')
			if get(tails, name) > 1
				let name = join(split(detail, '/')[-2:], '/')
			end
		end

		let line  = ''
		let line .= name

		if buflisted(b)
			let group = 'BuffersListed'
		else
			let group = 'BuffersUnlisted'
		end
		if is_terminal
			let group = 'BuffersTerminal'
		elseif is_modified
			let group = 'BuffersMod'
		end

		call add(matches, s:match_create(group, i, 0, len(line)+2))
		call add(matches, s:match_create('BuffersDim', i, len(line)+1))

		if len(split(detail, '/')) > 1
			let line .= ' ' . detail
		end

		call setbufline(a:bufnr, i, line)
		let i += 1

	endfo

	call setbufvar(a:bufnr, "&modifiable", 0)

	return [table, matches]

endf


" s:get_buffers([{all}]) -> list
" Return a list of 'normal' or 'terminal' buffers.
"
" Args:
"   - all (bool): if it's given and it's true, unlisted buffers are also returned
"
" Returns:
"   - buffers (list): a list of buffer numbers
"
func! s:get_buffers(...)
	let F1 = a:0 > 0 && a:1 ? function('bufexists') : function('buflisted')
	let F2 = {i, nr -> F1(nr) && getbufvar(nr, '&buftype') =~ '\v^(terminal)?$'}
	return filter(range(1, bufnr('$')), F2)
endf


" s:prettify_path({path}) -> string
" Prettify the given {path} by trimming the current working directory. If not
" successful, try to reduce file name to be relative to the home directory.
"
" Args:
"   - path (string): the path to prettify
"
" Returns:
"   - path (string): the prettified path
"
func! s:prettify_path(path)
	let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
	let path = substitute(path, '\V\^'.$HOME, '~', '')
	return path
endf


" s:resize_window({max_height}) -> 0
" Resize the current window.
"
" Args:
"   - max_height (number): window height as percentage of the Vim window
"
func s:resize_window(max_height) abort
	let max = float2nr(&lines * a:max_height / 100)
	exec 'resize' min([line('$'), max])
endf


" s:match_create({group}, {line}, [, {start}, [, {end}]]) -> dict
" Create a match for highlighting a {line} with the given highlight {group}.
" If neither {start} or {end} are given, the whole line is highlighted. If both
" {start} and {end} are given, the line is highlighted from column {start} to
" {end}. If only {start} is given, the line is highlighted starting from the
" column {start}.
"
" Args:
"   - group (string): the highlighting syntax group
"   - line (number): line to be highlighted
"   - start (number): start column
"   - end (number): end column
"
" Returns:
"   - match (dict): a single match dictionary as returned by `getmatches()`
"
func! s:match_create(group, line, ...)
	let start = a:0 > 0 && type(a:1) == v:t_number ? '%>'.a:1.'c.*' : ''
	let end = a:0 > 1 && type(a:2) == v:t_number ? '%<'.a:2.'c' : ''
	let line = '%'.a:line.'l' . (empty(start.end) ? '.*' : '')
	return {'group': a:group, "pattern": printf('\v%s%s%s', line, start, end), "priority": "", "id": s:id()}
endf


" s:err({msg}) -> 0
" Display a simple error message.
"
" Args:
"   - msg (string): the error message
"
func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
