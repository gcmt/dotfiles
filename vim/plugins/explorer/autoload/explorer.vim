
let s:bufname = '__explorer__'

aug _explorer
	au!
	au BufLeave __explorer__ call <sid>restore_alternate_buffer()
aug END

func! s:restore_alternate_buffer()
	if buflisted(b:explorer.alt)
		let @# = b:explorer.alt
	elseif buflisted(b:explorer.current)
		let @# = b:explorer.current
	end
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
		let b:explorer = {'current': current, 'alt': alternate, 'map': {}, 'tree': {}}
		let @# = buflisted(current) ? current : @#
	end

	let node = {}
	let node['path'] = path
	let node['filename'] = fnamemodify(path, ':t')
	let node['info'] = ''
	let node['content'] = []
	let node['parent'] = {}
	call explorer#tree#get_content(node)
	let b:explorer.tree = node

	call explorer#tree#render()

endf

func! explorer#err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
