
aug _explorer
	au!
	au BufLeave __explorer__ call <sid>restore_alternate()
aug END


func! s:restore_alternate()
	for nr in [b:explorer.alt, b:explorer.current] + range(1, bufnr('$'))
		if buflisted(nr)
			let @# = nr
			break
		end
	endfo
endf


func! explorer#open(target, curwin) abort

	let target = a:target
	let curwin = a:curwin

	if !empty(target)
		if !isdirectory(target) && !filereadable(target)
			return explorer#err("Invalid file or directory: %s", target)
		end
	end

	let explorer = {}

	if exists('b:explorer')
		let explorer = b:explorer
		let curwin = 1
	else
		let explorer.current = bufnr('%')
		let explorer.alt = bufnr('#')
	end

	if curwin
		sil edit __explorer__
	else
		sil keepj keepa botright new __explorer__
		let w:explorer = 1
	end

	setl filetype=explorer buftype=nofile bufhidden=hide nobuflisted
	setl noundofile nobackup noswapfile nospell
	setl nowrap nonumber norelativenumber nolist textwidth=0
	setl cursorline nocursorcolumn colorcolumn=0

	let b:explorer = extend(get(b:, 'explorer', {}), explorer)

	if empty(get(b:explorer, 'tree', {}))
		let target = fnamemodify(bufname(b:explorer.current), ':p')
	end

	if !empty(target)

		let target = substitute(fnamemodify(target, ':p'), '\v/+$', '', '')

		if isdirectory(target)
			let dir = target
		else
			let dir = fnamemodify(target, ':h')
		end

		let b:explorer.tree = explorer#tree#new_node(dir, 'dir')
		call b:explorer.tree.explore()
		call b:explorer.tree.render()

		if filereadable(target)
			let path = target
		else
			let path = fnamemodify(bufname(b:explorer.current), ':p')
		end

		if !explorer#actions#goto(path)
			call explorer#actions#goto_first_child(b:explorer.tree)
		end

		if line('w0') > 1
			norm! zz
		end

	else

		let winsave = winsaveview()
		call b:explorer.tree.render()
		call winrestview(winsave)

	end

endf


func! explorer#err(fmt, ...)
	echohl WarningMsg | echom call('printf', [a:fmt] + a:000)  | echohl None
endf
