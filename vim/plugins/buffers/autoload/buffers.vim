
let s:bufname = '__buffers__'

func! buffers#open() abort

	if bufwinnr(s:bufname) != -1
		return
	end

	if len(s:buffers()) == 1
		return s:err("No more buffers")
	end

	let current = bufnr('%')
	exec 'sil keepj keepa botright 1new' s:bufname
	let b:buffers = {'table': {}, 'current': current}
	setl filetype=buffers buftype=nofile bufhidden=delete nobuflisted
	setl noundofile nobackup noswapfile nospell
	setl nowrap nonumber norelativenumber nolist textwidth=0
	setl cursorline nocursorcolumn colorcolumn=0
	let b:buffers_laststatus_save = &laststatus
	au BufLeave <buffer> let &laststatus = b:buffers_laststatus_save
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

func! buffers#render()

	syntax clear
	setl modifiable
	let pos_save = getpos('.')
	sil %delete _

	let buffers = s:buffers()

	let tails = {}
	for bufnr in buffers
		let tail = fnamemodify(bufname(bufnr), ':t')
		let tails[tail] = get(tails, tail) + 1
	endfo

	let i = 1
	let b:buffers.table = {}
	for bufnr in buffers

		let b:buffers.table[i] = bufnr

		let name = bufname(bufnr)
		let path = empty(name) ? '' : s:prettify_path(fnamemodify(name, ':p'))

		let line = ''

		if empty(name)
			let tail = 'unnamed ('.bufnr.')'
		else
			let tail =  fnamemodify(path, ':t')
			if get(tails, tail) > 1
				let tail = join(split(path, '/')[-2:], '/')
			end
		end

		let line .= tail
		let line .= getbufvar(bufnr, '&mod') ? ' *' : ''
		if !empty(path) && path != tail
			exec 'syn match BuffersDim /\%'.i.'l\%'.(len(line)+1).'c.*/'
			let line .= ' ' . path
		end

		call setline(i, line)
		let i += 1

	endfor

	call s:resize_window()
	call setpos('.', pos_save)
	setl nomodifiable

endf

func! s:buffers()
	return filter(range(1, bufnr('$')), 'buflisted(v:val)')
endf

func! s:prettify_path(path)
	let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
	let path = substitute(path, '\V\^'.$HOME, '~', '')
	return path
endf

" Resize the current window according to g:taglist_max_winsize.
" That value is expected to be expressed in percentage.
func s:resize_window() abort
	let max = float2nr(&lines * g:buffers_max_winsize / 100)
	exec 'resize' min([line('$'), max])
endf

func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
