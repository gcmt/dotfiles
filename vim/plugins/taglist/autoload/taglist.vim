
let s:bufname = '__taglist__'

" Open the Taglist buffer and display all search matches.
" If there is only one match and a bang is provided, then it jumps directly to
" that match.
func taglist#open(bang, query) abort

	let tagfiles = s:tagfiles()
	let tags = s:search(a:query, tagfiles)
	if v:shell_error
		if empty(tags)
			return s:err("Nothing found")
		end
		return s:err(join(tags, "\n"))
	end

	if !empty(a:bang) && len(tags) == 1
		if bufwinnr(s:bufname) != -1
			exec bufwinnr(s:bufname) . 'wincmd c'
		end
		let path = substitute(tags[0].file, '\V\^'getcwd().'/', '', '')
		exec 'edit' fnameescape(path)
		exec tags[0].address
		norm! zz
		return
	end

	if bufwinnr(s:bufname) != -1
		exec bufwinnr(s:bufname) . 'wincmd w'
		let b:taglist.query = a:query
	else
		exec 'sil keepa botright 1new' s:bufname
		let b:taglist = {'table': {}, 'tagfiles': tagfiles, 'query': a:query, 'tags': []}
		setl filetype=taglist buftype=nofile bufhidden=hide nobuflisted
		setl noundofile nobackup noswapfile nospell
		setl nowrap nonumber norelativenumber nolist textwidth=0
		setl cursorline nocursorcolumn colorcolumn=0
	end

	call setwinvar(0, '&stl', ' taglist /'.b:taglist.query.'/%=')
	call taglist#render(tags)
	call cursor(1, 1)

endf

" Return all tagfiles.
func s:tagfiles() abort
	return split(&tags, ',')
endf

" Search for 'query' in all tagfiles using grep.
func s:search(query, tagfiles) abort
	let args = ['-m', g:taglist_max_results, '^'.a:query, '-w'] + a:tagfiles
	let args = map(args, 'shellescape(v:val)')
	let lines = systemlist('rg -j 1 -N -H --no-heading --no-messages' . ' ' . join(args))
	if v:shell_error
		return lines
	end
	return s:parse_matches(lines)
endf

" Parse ctags lines
func! s:parse_matches(lines) abort
	let tags = []
	for line in a:lines
		let tag = {}
		let tag.tagfile = matchstr(line, '\v^[^:]+')
		let tokens = split(matchstr(line, '\v:\zs.*'), '\t')
		let tag.name = tokens[0]
		let tag.file = tokens[1]
		let tag.address = tokens[2]
		let tag.meta = tokens[3:]
		if tag.address !~ '\v^\d+'
			let tag.address = '/\V\^' . tag.address[2:-5] . '\$/;"'
		end
		call add(tags, tag)
	endfo
	return tags
endf

" Render the Taglist buffer with the given tags
func taglist#render(...) abort

	if &filetype != 'taglist'
		throw "Taglist: not allowed here"
	end

	" If no tags are provided, use the ones that already exist
	let tags = a:0 > 0 && type(a:1) == v:t_list ? a:1 : b:taglist.tags
	let b:taglist.tags = tags

	syn clear
	setl modifiable
	sil %delete _

	syn match TaglistPipe /└/
	syn match TaglistPipe /─/
	syn match TaglistPipe /├/
	syn match TaglistPipe /│/

	let i = 1
	let b:taglist.table = {}
	let groups = s:group_tags(tags)
	for tagfile in s:tagfiles()

		if !has_key(groups, tagfile)
			continue
		end

		if g:taglist_visible_tagfiles
			call s:highlight('TaglistTagfile', i)
			let head = s:prettify_path(fnamemodify(tagfile, ':h'))
			let tail = substitute(fnamemodify(tagfile, ':t'), '\V\^\d\+\(.\|_\|-\)', '', '')
			call setline(i, head . '/' . tail)
			let i += 1
		end

		let y = 0
		for file in sort(keys(groups[tagfile]))

			let line = ''
			if g:taglist_visible_tagfiles
				let line = y == len(groups[tagfile])-1 ? '└─ ' : '├─ '
			end

			call s:highlight('TaglistFile', i, len(line))
			if !empty($VIRTUAL_ENV) && file =~ '\V\^'.$VIRTUAL_ENV . '/'
				let path = substitute(file, '\V\^'.$VIRTUAL_ENV.'/\.\*/site-packages/', '$venv/', '')
			else
				let path = s:prettify_path(file)
			end
			let line .= path
			call setline(i, line)
			let i += 1

			let link = ''
			if g:taglist_visible_tagfiles
				let link = y == len(groups[tagfile])-1 ? '   ' : '│  '
			end

			let k = 0
			for tag in groups[tagfile][file]
				let line = link . (k == len(groups[tagfile][file])-1 ? '└─' : '├─')
				let b:taglist.table[i] = tag
				if tag.address =~ '\v^\d+'
					let linenr = printf(" %4d", matchstr(tag.address, '\v\d+'))
					call s:highlight('TaglistLineNr', i, len(line)+1, len(line)+len(linenr)+2)
					let line .= linenr
				end
				let tagname = ' ' . tag.name
				call s:highlight('TaglistTagname', i, len(line), len(line)+len(tagname)+2)
				let line .= tagname
				let meta = ' ' . join(tag.meta, ' ')
				call s:highlight('TaglistMeta', i, len(line), len(line)+len(meta)+2)
				let line .= meta
				call setline(i, line)
				let k += 1
				let i += 1
			endfor

			let y += 1
		endfo

	endfor

	call s:resize_window()
	setl nomodifiable

endf

" Group tags.
" Output structure: {tagfile1: {file1: [tag1, tag2, ..], ..}, ..}
func! s:group_tags(tags)
	let groups = {}
	for tag in a:tags
		if !has_key(groups, tag.tagfile)
			let groups[tag.tagfile] = {}
		end
		if !has_key(groups[tag.tagfile], tag.file)
			let groups[tag.tagfile][tag.file] = []
		end
		call add(groups[tag.tagfile][tag.file], tag)
	endfor
	return groups
endf

" Highlight a line with the given highlight group.
" Start and end columns might be given as well.
func! s:highlight(group, line, ...)
	let start = a:0 > 0 && type(a:1) == v:t_number ? '%>'.a:1.'c.*' : ''
	let end = a:0 > 1 && type(a:2) == v:t_number ? '%<'.a:2.'c' : ''
	let line = '%'.a:line.'l' . (empty(start.end) ? '.*' : '')
	exec printf('syn match %s /\v%s%s%s/', a:group, line, start, end)
endf

" Prettify path.
func s:prettify_path(path) abort
	let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
	return substitute(path, '\V\^'.$HOME, '~', '')
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
