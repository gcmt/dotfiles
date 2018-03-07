
let s:bufname = '__finder__'

func finder#findg(path, query) abort
	if empty(a:query)
		return s:err('Empty query')
	end
	let cmd = printf('rg -l %s %s', shellescape(a:query), shellescape(a:path))
	let results = systemlist(cmd)
	if v:shell_error
		return s:err(join(results, "\n"))
	end
	call s:view_results(results)
endf


func finder#find(path, query) abort
	if empty(a:query)
		return s:err('Empty query')
	end
	let input = system('rg --files ' . shellescape(a:path))
	let results = systemlist('rg ' . shellescape(a:query), input)
	if v:shell_error
		return s:err(join(results, "\n"))
	end
	call s:view_results(results)
endf

func s:view_results(results) abort
	if empty(a:results)
		return s:err("Nothing found")
	end
	if bufwinnr(s:bufname) != -1
		" if the buffer is already visible, just move there
		exec bufwinnr(s:bufname).'wincmd w'
	else
		exec 'sil keepj keepa botright 1new' s:bufname
		let b:finder = {'table': {}}
		setl filetype=finder buftype=nofile bufhidden=delete nobuflisted
		setl noundofile nobackup noswapfile nospell
		setl nowrap nonumber norelativenumber nolist textwidth=0
		setl cursorline nocursorcolumn colorcolumn=0
		let b:finder_laststatus_save = &laststatus
		au BufLeave <buffer> let &laststatus = b:finder_laststatus_save
		setl laststatus=0
		echo
	end
	call s:render(a:results[:g:finder_max_results])
	norm! gg
endf

func s:render(files) abort

	syntax clear
	setl modifiable
	sil %delete _

	call s:resize_window(len(a:files))

	let text = []
	let b:finder.table = {}
	for [i, path] in map(copy(a:files), '[v:key+1, v:val]')

		let line = ''
		let b:finder.table[i] = path
		let path = s:prettify_path(path)

		let tail = fnamemodify(path, ':t')
		let line .= tail

		if path != tail
			exec 'syn match FinderDim /\%'.i.'l\%'.(len(line)+1).'c.*/'
			let line .= ' ' . path
		end

		call add(text, line)

	endfor

	call setline(1, text)

	setl nomodifiable

endf

func s:resize_window(entries_num)
	let max = float2nr(&lines * g:finder_max_winsize / 100)
	let min = float2nr(&lines * g:finder_min_winsize / 100)
	exec 'resize' max([min([a:entries_num, max]), min])
endf

func s:prettify_path(path)
	let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
	let path = substitute(path, '\V\^'.$HOME, '~', '')
	return path
endf

func s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
