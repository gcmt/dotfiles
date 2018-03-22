
let s:bufname = '__plugs__'

func! plugs#show() abort

	if !isdirectory(g:plugs_path)
		return s:err("Plugs: 'g:plugs_path' must be a valid directory")
	end

	" if the buffer is already visible, just move there
	let winnr = bufwinnr(s:bufname)
	if winnr != -1
		exec winnr.'wincmd w'
		return
	end

	let current = bufnr('%')
	exec 'sil keepj keepa botright 1new' s:bufname
	let b:plugs = {'table': {}, 'current': current}
	setl filetype=plugs buftype=nofile bufhidden=delete nobuflisted
	setl noundofile nobackup noswapfile nospell
	setl nowrap nonumber norelativenumber nolist textwidth=0
	setl cursorline nocursorcolumn colorcolumn=0
	call setwinvar(winnr(), '&stl', ' ' . fnamemodify(g:plugs_path, ':~') . '%=plugs ')

	call plugs#render()
	call cursor(1, 1)

endf

func! plugs#render()

	if &filetype != 'plugs'
		throw "Plugs: not allowed here"
	end

	let pos_save = getpos('.')

	syntax clear
	setl modifiable
	sil %delete _

	let listed = {}
	for repo in g:plugs_list
		let name = split(repo, '/')[-1]
		let listed[name] = repo
	endfo

	let installed = {}
	for path in filter(glob(g:plugs_path.'/*', 1, 1), 'isdirectory(v:val)')
		let name = split(path, '/')[-1]
		let installed[name] = 1
	endfor

	let i = 1
	let b:plugs.table = {}
	for name in sort(keys(extend(copy(listed), installed, 'keep')))
		let b:plugs.table[i] = {'name': name, 'url': get(listed, name, '')}
		let line = ''
		if has_key(listed, name) && has_key(installed, name)
			exec 'syn match PlugsInstalled /\v%'.i.'l^\S+/'
			let line .= name
			exec 'syn match PlugsDim /\%'.i.'l\%'.(len(line)+1).'c.*/'
			let line .= ' ' . get(listed, name)
		elseif has_key(listed, name) && !has_key(installed, name)
			exec 'syn match PlugsNotInstalled /\v%'.i.'l^\S+/'
			let line .= name
			exec 'syn match PlugsDim /\%'.i.'l\%'.(len(line)+1).'c.*/'
			let line .= ' ' . get(listed, name)
		elseif !has_key(listed, name) && has_key(installed, name)
			exec 'syn match PlugsOrphan /\v%'.i.'l^\S+/'
			let line .= name
			exec 'syn match PlugsDim /\%'.i.'l\%'.(len(line)+1).'c.*/'
			let line .= ' not listed'
		end
		call setline(i, line)
		let i += 1
	endfor

	call s:resize_window(line('$'))
	call setpos('.', pos_save)
	setl nomodifiable

endf

func! s:resize_window(entries_num)
	let max = float2nr(&lines * g:plugs_max_winsize / 100)
	let min = float2nr(&lines * g:plugs_min_winsize / 100)
	exec 'resize' max([min([a:entries_num, max]), min])
endf

func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
