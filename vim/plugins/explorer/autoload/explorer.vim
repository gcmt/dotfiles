
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

	if !empty(a:path) && !isdirectory(a:path)
		return explorer#err(printf("Directory '%s' does not exist", a:path))
	end

	let current = bufnr('%')
	let alternate = bufnr('#')

	sil edit __explorer__
	setl filetype=explorer buftype=nofile bufhidden=delete nobuflisted
	setl noundofile nobackup noswapfile nospell
	setl nowrap nonumber norelativenumber nolist textwidth=0
	setl cursorline nocursorcolumn colorcolumn=0

	let b:explorer = exists('t:explorer') && empty(a:path) ? t:explorer : {}
	let b:explorer.current = current
	let b:explorer.alt = alternate

	if empty(get(b:explorer, 'tree', {}))
		let path = empty(a:path) ? getcwd() : a:path
		let root = g:explorer#tree#node.new(path)
		if !root.get_content()
			return explorer#err('Could not retrieve content for ' . root.path)
		end
		let b:explorer.tree = root
	end

	call b:explorer.tree.render()
	let path = fnamemodify(bufname(b:explorer.current), ':p')
	call explorer#actions#goto(path)

endf

func! explorer#err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
