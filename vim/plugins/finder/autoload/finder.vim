
let s:bufname = '__finder__'

func finder#find(prg, query) abort
	let res = s:search(a:prg, a:query)
	if !empty(res.err)
		return s:err(res.err)
	end
	if empty(res.matches)
		return s:err("Nothing found")
	end
	if len(res.matches) == 1
		exec 'edit' fnameescape(res.matches[0])
	else
		call s:view_results(a:query, res.matches)
	end
endf

func s:view_results(query, matches) abort
	if bufwinnr(s:bufname) != -1
		" if the buffer is already visible, just move there
		exec bufwinnr(s:bufname).'wincmd w'
	else
		exec 'sil keepj keepa botright 1new' s:bufname
		setl filetype=finder buftype=nofile bufhidden=delete nobuflisted
		setl noundofile nobackup noswapfile nospell
		setl nowrap nonumber norelativenumber nolist textwidth=0
		setl cursorline nocursorcolumn colorcolumn=0
		let b:finder = {'table': {}}
	end
	call setwinvar(winnr(), '&stl', ' :Find ' . a:query)
	call s:render(a:matches)
	norm! gg
endf

" Return all files that match the given query
func s:search(prg, query) abort
	let last_err = ''
	let query = join(map(split(a:query), 'shellescape(v:val)'))
	let out = systemlist(printf(a:prg, query))
	if v:shell_error
		return {'matches': [], 'err': join(out, "\n")}
	end
	let matches = out[:g:finder_max_results]
	return {'matches': matches, 'err': ''}
endf

func s:render(matches) abort

	syntax clear
	setl modifiable
	sil %delete _

	call s:resize_window(len(a:matches))

	let text = []
	let b:finder.table = {}
	for [i, path] in map(copy(a:matches), '[v:key+1, v:val]')

		let line = ''
		let b:finder.table[i] = path
		let path = s:prettify_path(path)

		let tail = fnamemodify(path, ':t')
		let line .= tail

		if path != tail
			exec 'syn match FinderDim /\%'.i.'l\%'.(len(line)+1).'c.*/'
			let line .= ',' . path
		end

		call add(text, line)

	endfor

	call setline(1, text)

	%!column -t -s ',' -o '  '

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
