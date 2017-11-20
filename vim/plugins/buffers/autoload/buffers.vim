
let s:bufname = '__buffers__'

func! buffers#open() abort

	" if the buffer is already visible, just move there
	let winnr = bufwinnr(s:bufname)
	if winnr != -1
		exec winnr.'wincmd w'
		return
	end

	if len(s:buffers()) == 1
		return s:err("No more buffers")
	end

	let current = bufnr('%')
	exec 'sil keepj keepa botright 1new' s:bufname
	call s:setup_buffer(current)

	call buffers#render_buffers()
	norm! gg

	" position the cursor on the current buffer
	for [line, bufnr] in items(b:buffers.table)
		if bufnr == current
			call cursor(line, 1)
			break
		end
	endfor

endf

func! s:buffers()
	return filter(range(1, bufnr('$')), 'buflisted(v:val)')
endf

func! s:setup_buffer(current)
	let b:buffers = {'table': {}, 'current': a:current}
	setl filetype=buffers buftype=nofile bufhidden=delete nobuflisted
	setl noundofile nobackup noswapfile nospell
	setl nowrap nonumber norelativenumber nolist textwidth=0
	setl cursorline nocursorcolumn colorcolumn=0
	setl stl=\ :Buffers
endf

func! buffers#render_buffers()

	if &filetype != 'buffers'
		throw "Buffers: not allowed here"
	end

	syntax clear
	setl modifiable
	sil %delete _

	let buffers = s:buffers()
	call s:resize_window(len(buffers))

	let text = []
	let b:buffers.table = {}
	for [i, nr] in map(copy(buffers), '[v:key+1, v:val]')

		let b:buffers.table[i] = nr

		let name = bufname(nr)
		let path = empty(name) ? '' : s:prettify_path(fnamemodify(name, ':p'))
		let tail = empty(name) ? 'unnamed_'.nr : fnamemodify(path, ':t')

		let line = ''
		let line .= tail
		let line .= getbufvar(nr, '&mod') ? ' * ' : ''
		if !empty(path) && path != tail
			exec 'syn match BuffersDim /\%'.i.'l\%'.(len(line)+1).'c.*/'
			let line .= ' ' . path
		end

		call add(text, line)

	endfor

	call setline(1, text)
	setl nomodifiable

endf

func! s:prettify_path(path)
	let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
	let path = substitute(path, '\V\^'.$HOME, '~', '')
	return path
endf

func! s:resize_window(entries_num)
	let max = float2nr(&lines * g:buffers_max_winsize / 100)
	exec 'resize' a:entries_num < max ? a:entries_num : max
endf

func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
