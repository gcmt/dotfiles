
aug _explorer
	au!
	au BufLeave __explorer__ call <sid>save_state()
	au BufLeave __explorer__ call <sid>restore_alternate()
aug END

func! s:save_state()
	let t:explorer = b:explorer
endf

func! s:restore_alternate()
	for nr in [b:explorer.alt, b:explorer.current] + range(1, bufnr('$'))
		if buflisted(nr)
			let @# = nr
			break
		end
	endfo
endf

func! explorer#open(path) abort

	if exists('b:explorer')
		return
	end

	" Allow arguments such as %:p:h, etc
	let path = expand(a:path)

	if !empty(path) && !isdirectory(path)
		return explorer#err(printf("Directory '%s' does not exist", path))
	end

	let current = bufnr('%')
	let alternate = bufnr('#')

	sil edit __explorer__
	setl filetype=explorer buftype=nofile bufhidden=delete nobuflisted
	setl noundofile nobackup noswapfile nospell
	setl nowrap nonumber norelativenumber nolist textwidth=0
	setl cursorline nocursorcolumn colorcolumn=0

	let b:explorer = exists('t:explorer') && empty(path) ? t:explorer : {}
	let b:explorer.current = current
	let b:explorer.alt = alternate

	if empty(get(b:explorer, 'tree', {}))
		let path = empty(path) ? getcwd() : path
		let root = explorer#tree#new_node(path)
		call root.get_content()
		let b:explorer.tree = root
	end

	call b:explorer.tree.render()

	let path = fnamemodify(bufname(b:explorer.current), ':p')
	if !explorer#actions#goto(path)
		call explorer#actions#goto_first_child(b:explorer.tree)
	end

endf

func! explorer#err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
