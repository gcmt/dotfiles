
let s:bufname = '__taglist__'

func taglist#find(bang, query) abort
	let matches = s:search(a:query)
	if v:shell_error
		if empty(matches)
			return s:err("Nothing found")
		end
		return s:err(join(matches, "\n"))
	end
	if !empty(a:bang) && len(matches) == 1
		" when a bang is provided and there is just one match,
		" jump directly to that match
		if bufwinnr(s:bufname) != -1
			exec bufwinnr(s:bufname).'wincmd c'
		end
		let match = matchstr(matches[0], '\v:\zs.*')
		let tag = s:parse_match(match)
		let path = substitute(tag.file, getcwd().'/', '', '')
		exec 'edit' fnameescape(path)
		exec tag.address
		return
	end
	call s:open(a:query)
	call s:render(matches)
	norm! ggj
endf

" Create the Taglist buffer or just move to it if already visible.
func s:open(query) abort
	if bufwinnr(s:bufname) != -1
		exec bufwinnr(s:bufname).'wincmd w'
	else
		exec 'sil keepj keepa botright 1new' s:bufname
		setl filetype=taglist buftype=nofile bufhidden=delete nobuflisted
		setl noundofile nobackup noswapfile nospell
		setl nowrap nonumber norelativenumber nolist textwidth=0
		setl cursorline nocursorcolumn colorcolumn=0
		let b:taglist_laststatus_save = &laststatus
		au BufLeave <buffer> let &laststatus = b:taglist_laststatus_save
		setl laststatus=0
		let b:taglist = {'table': {}}
	end
endf

" Search for 'query' in all tagfiles using grep.
func s:search(query) abort
	let args = ['-m', g:taglist_max_results, '^'.a:query, '-w'] + s:tagfiles()
	let args = map(args, 'shellescape(v:val)')
	return systemlist(g:taglist_grepprg . ' ' . join(args))
endf

" Return all tagfiles.
func s:tagfiles() abort
	return split(&tags, ',')
endf

" Render the Taglist buffer with the given matches
func s:render(matches) abort

	if &filetype != 'taglist'
		throw "Taglist: not allowed here"
	end

	syntax clear
	setl modifiable
	sil %delete _

	exec 'syn match TaglistPath /\v[^]]+$/'
	exec 'syn match TaglistTitle /\v^##.*/'
	exec 'syn match TaglistMeta /\v\[[^]]+\]/'

	let groups = s:group_matches(a:matches)
	call s:resize_window(len(a:matches) + len(groups))

	let i = 1
	let text = []
	let b:taglist.table = {}
	for [group, matches] in groups
		" strip leading numbers followed by dot (used to enforce ordering)
		let title = substitute(fnamemodify(group, ':t'), '\v^\d+\.?', '', '')
		call add(text, '## ' . title)
		for m in matches
			let i += 1
			let tag = s:parse_match(m)
			let b:taglist.table[i] = tag
			let path = s:prettify_path(tag.file)
			let meta = join(map(tag.meta, '"[".v:val."]"'))
			let line = tag.name . ' ' . meta . ' ' . path
			call add(text, line)
		endfor
		let i += 1
	endfor

	call setline(1, text)
	setl nomodifiable

endf

" Group matches of the same tag file.
" Matches are grep results in the form <tagfile>:<match>
" Groups are in the form [[<tagfile>, [<match1>, <match2>, ..]], ..]
func s:group_matches(matches) abort
	let groups = []
	for m in a:matches
		let tagfile = matchstr(m, '\v^[^:]+')
		if get(groups, -1, ['', []])[0] != tagfile
			call add(groups, [tagfile, []])
		end
		call add(groups[-1][1], matchstr(m, '\v:\zs.*'))
	endfor
	return groups
endf

" Remove noise from a path.
func s:prettify_path(path) abort
	let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
	let path = substitute(path, '\V\^/usr/local/Cellar', '/..', '')
	let path = substitute(path, '\V\^'.$HOME, '~', '')
	return path
endf

" Parse a single tagfile line.
func s:parse_match(line) abort
	let tag = {}
	let tokens = split(a:line, '\t')
	let tag.name = tokens[0]
	let tag.file = tokens[1]
	let tag.address = tokens[2]
	let tag.meta = tokens[3:]
	return tag
endf

func s:resize_window(lines) abort
	let max = float2nr(&lines * g:taglist_max_winsize / 100)
	exec 'resize' min([a:lines, max])
endf

func s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
