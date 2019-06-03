
let s:bufname = '__buffers__'

" buffers#view({all:number}) -> 0
" View the buffers list in a window at the bottom. If {all} is given and it's
" true, then also 'normal' unlisted buffers are displayed.
func! buffers#view(all) abort

	if bufwinnr(s:bufname) != -1
		return
	end

	if len(s:buffers(a:all)) == 1
		return s:err("No more buffers")
	end

	let current = bufnr('%')
	let winnr = winnr()
	exec 'sil keepj keepa botright 1new' s:bufname
	let b:buffers = {'table': {}, 'current': current, 'winnr': winnr, 'all': a:all}
	setl filetype=buffers buftype=nofile bufhidden=hide nobuflisted
	setl noundofile nobackup noswapfile nospell
	setl nowrap nonumber norelativenumber nolist textwidth=0
	setl cursorline nocursorcolumn colorcolumn=0
	exec 'au BufHidden <buffer> let &laststatus = ' &laststatus
	setl laststatus=0
	echo

	call buffers#render()

	" move the cursor to the current buffer
	call cursor(1, 1)
	for [line, bufnr] in items(b:buffers.table)
		if bufnr == current
			call cursor(line, 1)
			break
		end
	endfor

endf

" s:buffers#render() -> 0
" Render the buffers list in the current buffer.
func! buffers#render()

	syntax clear
	setl modifiable
	sil %delete _
	let cursor_line = 1

	let buffers = s:buffers(b:buffers.all)

	let tails = {}
	for bufnr in buffers
		let tail = fnamemodify(bufname(bufnr), ':t')
		let tails[tail] = get(tails, tail) + 1
	endfo

	let i = 1
	let b:buffers.table = {}
	for bufnr in buffers

		let b:buffers.table[i] = bufnr

		let is_terminal = getbufvar(bufnr, '&bt') == 'terminal'
		let is_modified = getbufvar(bufnr, '&mod')

		let name = bufname(bufnr)

		if empty(name)
			let name = bufnr
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

		if buflisted(bufnr)
			let group = 'BuffersListed'
		else
			let group = 'BuffersUnlisted'
		end

		if is_terminal
			let group = 'BuffersTerminal'
		elseif is_modified
			let group = 'BuffersMod'
		end

		call s:highlight(group, i, 0, len(line)+2)

		call s:highlight('BuffersDim', i, len(line)+1)

		if !empty(detail) && detail != name
			let line .= ' ' . detail
		end

		if bufnr == b:buffers.current
			let cursor_line = i
		end

		call setline(i, line)
		let i += 1

	endfo

	setl nomodifiable
	call s:resize_window()
	norm! gg
	exec cursor_line

endf

" s:buffers([{all:number}]) -> list
" Return a list of 'normal' or 'terminal' buffers).
" If {all} is given and it's true, unlisted buffers are also returned.
func! s:buffers(...)
	let F1 = a:0 > 0 && a:1 ? function('bufexists') : function('buflisted')
	let F2 = {i, nr -> F1(nr) && getbufvar(nr, '&buftype') =~ '\v^(terminal)?$'}
	return filter(range(1, bufnr('$')), F2)
endf

" s:prettify_path({path:string}) -> string
" Prettify the given {path} by trimming the current working directory.
" If not successful, try to reduce file name to be relative to the home directory.
func! s:prettify_path(path)
	let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
	let path = substitute(path, '\V\^'.$HOME, '~', '')
	return path
endf

" s:resize_window() -> 0
" Resize the current window according to the value g:buffers_max_winsize,
" which is expected to be expressed as a percentage of the Vim window
func s:resize_window() abort
	let max = float2nr(&lines * g:buffers_max_winsize / 100)
	exec 'resize' min([line('$'), max])
endf

" s:highlight({group:string}, {line:number}, [, {start:number}, [, {end:number}]]) -> 0
" Highlight a {line} with the given highlight {group}.
" If neither {start} or {end} are given, the whole line is highlighted.
" If both {start} and {end} are given, the line is highlighted from columns
" {start} to {end}.
" If only {start} is given, the line is highlighted starting from the column
" {start}.
func! s:highlight(group, line, ...)
	let start = a:0 > 0 && type(a:1) == v:t_number ? '%>'.a:1.'c.*' : ''
	let end = a:0 > 1 && type(a:2) == v:t_number ? '%<'.a:2.'c' : ''
	let line = '%'.a:line.'l' . (empty(start.end) ? '.*' : '')
	exec printf('syn match %s /\v%s%s%s/', a:group, line, start, end)
endf

" s:err({msg:string}) -> 0
" Display a simple error message.
func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
