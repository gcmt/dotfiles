
let s:bufname = '__explorer__'

aug _explorer
	au!
	au BufLeave __explorer__ call <sid>restore_alternate_buffer()
aug END

func! s:restore_alternate_buffer()
	let @# = buflisted(b:explorer.alt) ? b:explorer.alt : b:explorer.current
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
		let b:explorer = {'current': current, 'alt': alternate, 'table': {}}
		let @# = buflisted(current) ? current : @#
	end

	call explorer#buffer#render(path)
	call explorer#utils#set_cursor(@#)

endf

func! explorer#err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
