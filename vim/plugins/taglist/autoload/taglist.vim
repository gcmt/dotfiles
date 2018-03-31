
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
		call setwinvar(0, '&stl', ' taglist')
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

	syn clear
	setl modifiable
	sil %delete _

	let i = 1
	let b:taglist.table = {}
	for [tagfile, matches] in s:group_matches_by_file(a:matches)

		call matchadd('TaglistTagfile', '\v%'.i.'l.*')
		let line = s:prettify_path(tagfile)
		call setline(i, line)
		let i += 1

		let k = 0
		for m in matches
			let line = k == len(matches)-1 ? '└──' : '├──'
			call matchadd('TaglistLink', '\v%'.i.'l%<'.(len(line)).'c')
			let tag = s:parse_match(m)
			let b:taglist.table[i] = tag
			let tagname = ' ' . tag.name
			call matchadd('TaglistTagname', '\v%'.i.'l%>'.(len(line)).'c.*%<'.(len(line)+len(tagname)+1).'c')
			let line .= tagname
			let meta = ' ' . join(map(tag.meta, '"[".v:val."]"'))
			call matchadd('TaglistMeta', '\v%'.i.'l%>'.(len(line)).'c.*%<'.(len(line)+len(meta)+1).'c')
			let line .= meta
			call matchadd('TaglistPath', '\v%'.i.'l%'.(len(line)+1).'c.*')
			let line .= ' ' . s:prettify_path(tag.file)
			call setline(i, line)
			let k += 1
			let i += 1
		endfor

	endfor

	call s:resize_window()
	setl nomodifiable

endf

" Group matches of the same tag file.
" Matches are grep results in the form <tagfile>:<match>
" Groups are in the form [[<tagfile>, [<match1>, <match2>, ..]], ..]
func s:group_matches_by_file(matches) abort
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

" Resize the current window according to g:taglist_max_winsize.
" That value is expected to be expressed in percentage.
func s:resize_window() abort
	let max = float2nr(&lines * g:taglist_max_winsize / 100)
	exec 'resize' min([line('$'), max])
endf

func s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
