
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

func! explorer#open(arg) abort

	if exists('b:explorer')
		return
	end

	let arg = a:arg
	let explorer = {}

	if empty(arg)
		if exists('t:explorer')
			let explorer = t:explorer
		else
			let arg = getcwd()
		end
	end

	if empty(explorer)

		if arg =~ '\V\^scp://'
			let match = matchlist(arg, '\v^scp://([^/]+)/?(.*)')
			if empty(match)
				return explorer#err('Invalid argument')
			end
			let path = match[2]
			let explorer.host = match[1]
			let explorer.protocol = 'scp'
		else
			let path = substitute(fnamemodify(arg, ':p'), '\v/+$', '', '')
			let explorer.host = 'localhost'
			let explorer.protocol = ''
		end

		if explorer.protocol == 'scp'
			let out = system('ssh ' . explorer.host . ' ls -ldh ' . shellescape(path))
			if out !~ '\v^\s*d'
				return explorer#err("Directory does not exist: " . explorer.host.'/'.path)
			end
		elseif !isdirectory(path)
			return explorer#err("Directory does not exist: " . path)
		end

	end

	let explorer.current = bufnr('%')
	let explorer.alt = bufnr('#')

	sil edit __explorer__
	setl filetype=explorer buftype=nofile bufhidden=wipe nobuflisted
	setl noundofile nobackup noswapfile nospell
	setl nowrap nonumber norelativenumber nolist textwidth=0
	setl cursorline nocursorcolumn colorcolumn=0

	let b:explorer = explorer

	if empty(get(b:explorer, 'tree', {}))
		let b:explorer.tree = explorer#tree#new_node(path, 'dir')
		call b:explorer.tree.explore()
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
