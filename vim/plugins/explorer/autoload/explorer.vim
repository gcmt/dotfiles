
let s:bufname = '__explorer__'

aug _explorer
	au!
	au BufLeave __explorer__ call <sid>restore_alternate_buffer()
aug END

func! s:restore_alternate_buffer()
	let @# = buflisted(b:explorer.alt) ? b:explorer.alt : b:explorer.current
endf

func! explorer#toggle_hidden_files()
	let g:explorer_hidden_files = 1 - g:explorer_hidden_files
	let line_save = getline('.')
	let linenr_save = line('.')
	call explorer#render(b:explorer.dir)
	if !search('\V\^' . substitute(line_save, '\v\s+', '\\s\\+', 'g'))
		exec linenr_save
	end
endf

func! explorer#render(path)

	let [files, errmsg] = s:ls(a:path, g:explorer_hidden_files)
	if !empty(errmsg)
		call s:err(errmsg)
		return
	end

	let b:explorer.dir = a:path
	call s:set_statusline(a:path)

	syntax clear
	setl modifiable
	sil %delete _

	let max_length = 0
	for [fname, _] in files
		if strlen(fname) > max_length
			let max_length = strlen(fname)
		end
	endfo

	let meta_start = max_length + 4
	exec 'syn match ExplorerDim /\v%>'.meta_start.'c.*/'

	let text = []
	let linenr = 1
	for [fname, meta] in files
		let b:explorer.table[linenr] = fname
		let line = fname
		if meta.perms[0] == 'd'
			let line .= '/'
			exec 'syn match ExplorerDir /\v%'.linenr.'l.%<'.(len(line)+2).'c/'
		end
		let line .= repeat(' ', meta_start - len(line))
		let line .= ',' . meta.perms
		let line .= ',' . meta.nlinks
		let line .= ',' . meta.user
		let line .= ',' . meta.group
		let line .= ',' . meta.size
		let line .= ',' . meta.modtime
		let line .= !empty(meta.link) ? ',-> ' . meta.link : ''
		call add(text, line)
		let linenr += 1
	endfo

	call setline(1, text)

	1,$!column -t -s ',' -o '  '

	setl nomodifiable

endf

func! explorer#open(path) abort

	let path = empty(a:path) ? getcwd() : a:path
	if !isdirectory(path)
		call s:err(printf("Directory '%s' does not exist", path))
		return
	end

	if !exists('b:explorer')
		let alt = bufnr('#')
		let current = bufnr('%')
		call s:new_buffer(current, alt)
	end

	call explorer#render(path)

	call s:set_cursor(@#)

endf

func! explorer#up_dir() abort
	if b:explorer.dir == '/'
		return
	end
	let current = b:explorer.dir
	let parent = fnamemodify(b:explorer.dir, ':h')
	call explorer#render(parent)
	call s:set_cursor(current)
endf

func! explorer#enter_or_edit() abort
	let tail = get(b:explorer.table, line('.'), '')
	if empty(tail)
		return
	end
	let path = b:explorer.dir . (b:explorer.dir == '/' ? tail : '/' . tail)
	if isdirectory(path)
      call explorer#render(path)
		norm! M
	else
		let current = b:explorer.current
		exec 'edit' fnameescape(path)
		let @# = buflisted(current) ? current : bufnr('%')
	end
endf

func! s:new_buffer(current, alt)
	exec 'sil edit' s:bufname
	setl filetype=explorer buftype=nofile bufhidden=delete nobuflisted
	setl noundofile nobackup noswapfile nospell
	setl nowrap nonumber norelativenumber nolist textwidth=0
	setl cursorline nocursorcolumn colorcolumn=0
	let b:explorer = {'current': a:current, 'alt': a:alt, 'table': {}}
	if buflisted(a:current)
		let @# = a:current
	end
endf

func! s:set_statusline(path)
	let hidden_flag = ''
	if g:explorer_hidden_files
		let hidden_flag = '[H] '
	end
	let stl = ' ' . hidden_flag . substitute(a:path, $HOME, '~', '')[:-1] . '%=explorer '
	call setwinvar(0, '&stl', stl)
endf

func! s:set_cursor(path)
	norm! gg
	if search('\V\^' . fnamemodify(a:path, ':t') . '/\?\s')
		norm! zz
	end
endf

func! s:ls(path, hidden)

	let out = systemlist(printf("ls %s -lAh", shellescape(a:path)))
	if v:shell_error
		return [[], out[0]]
	end

	let dirs = []
	let hidden_dirs = []
	let files = []
	let hidden_files = []

	for line in out[1:]

		let m = matchlist(line, '\v^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\w\w\w\s+\d\d?\s+\d\d:\d\d)\s+(.*)')
		call filter(m, '!empty(v:val)')
		if empty(m)
			" echom "line didn't match >>" line
			continue
		end

		let link = ''
		let fname = m[7]

		if fname =~ '\V->'
			let link = matchstr(fname, '\V->\s\+\zs\.\*')
			let fname = substitute(fname, '\V\s\+->\.\*', '', '')
		end

		if fname[0] == '.' && !a:hidden
			continue
		end

		if fname =~# '\v('.join(split(g:explorer_hide, ','), '|').')'
			continue
		end

		let file = [fname, {
			\ 'fname': fname,
			\ 'link': link,
			\ 'perms': m[1],
			\ 'nlinks': m[2],
			\ 'user': m[3],
			\ 'group': m[4],
			\ 'size': m[5],
			\ 'modtime': m[6],
		\ }]

		if isdirectory(a:path . '/' . fname)
			if fname[0] == '.'
				call add(hidden_dirs, file)
			else
				call add(dirs, file)
			end
		else
			if fname[0] == '.'
				call add(hidden_files, file)
			else
				call add(files, file)
			end
		end

	endfo

	let content = sort(dirs) + sort(hidden_dirs) + sort(files) + sort(hidden_files)
	return [content, '']
endf

func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
