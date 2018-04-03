
let s:bufname = '__explorer__'

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

func! explorer#open(path) abort

	let path = empty(a:path) ? getcwd() : a:path
	if !isdirectory(path)
		return explorer#err(printf("Directory '%s' does not exist", path))
	end

	if !exists('b:explorer')
		let current = bufnr('%')
		let alternate = bufnr('#')
		exec 'silent edit' s:bufname
		setl filetype=explorer buftype=nofile bufhidden=delete nobuflisted
		setl noundofile nobackup noswapfile nospell
		setl nowrap nonumber norelativenumber nolist textwidth=0
		setl cursorline nocursorcolumn colorcolumn=0
		let b:explorer = {'current': current, 'alt': alternate}
	end

	let root = g:explorer#tree#node.new(path)
	if !root.get_content()
		return explorer#err('Could not retrieve content for ' . root.path)
	end
	let b:explorer.tree = root
	call b:explorer.tree.render()
	let path = fnamemodify(bufname(b:explorer.current), ':p')
	call explorer#actions#goto(path)

endf

func! explorer#err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
