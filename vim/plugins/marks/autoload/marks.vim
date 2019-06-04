
let s:bufname = '__marks__'

" Return all [a-zA-Z] marks.
func! marks#marks()
	let marks = {}
	for line in split(execute('marks'), "\n")[1:]
		let match = matchlist(line, '\v\s([a-zA-Z])\s+(\d+)\s+(\d+)\s+(.*)')
		if empty(match)
			continue
		end
		let mark = {'letter': match[1], 'linenr': str2nr(match[2]), 'colnr': str2nr(match[3])}
		let path = fnamemodify(match[4], ':p')
		let mark.file = filereadable(path) ? path : fnamemodify(bufname('%'), ':p')
		let mark.line = get(getbufline(mark.file, mark.linenr), 0, '')
		let marks[match[1]] = mark
	endfo
	return marks
endf

" Automatically mark the current line.
" If the mark already exists, then it is deleted.
func! marks#set_auto(local) abort
	let marks = marks#marks()
	let path = fnamemodify(bufname('%'), ':p')
	for mark in values(marks)
		if mark.file == path && mark.linenr == line('.') && mark.line == getline('.')
			exec 'delmarks' mark.letter
			echo printf("line \"%s\" unmarked [%s]", line('.'), mark.letter)
			return
		end
	endfo
	let letters = a:local ? 'abcdefghijklmnopqrstuvwxyz' : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	for letter in split(letters, '\ze')
		if !has_key(marks, letter)
			exec 'mark' letter
			echo printf("line \"%s\" marked with [%s]", line('.'), letter)
			return
		end
	endfo
	call marks#err("No more marks available")
endf

" Open the buffer where marks will be displayed
func! marks#view() abort

	if bufwinnr(s:bufname) != -1
		return
	end

	let marks = marks#marks()
	if empty(marks)
		return marks#err("No marks found")
	end

	let current = fnamemodify(bufname('%'), ':p')
	exec 'sil keepa botright 1new' s:bufname
	let b:marks = {'table': {}, 'buffer': current}
	setl filetype=marks buftype=nofile bufhidden=hide nobuflisted
	setl noundofile nobackup noswapfile nospell
	setl nowrap nonumber norelativenumber nolist textwidth=0
	setl cursorline nocursorcolumn colorcolumn=0
	call setwinvar(0, '&stl', ' marks')

	call marks#render(marks)
	call cursor(1, 1)
	call search('\V\^'.s:prettify_path(current))

endf

" Populate the 'marks' buffer with nicely formatted data
func! marks#render(marks)

	if &filetype != 'marks'
		throw "Marks: not allowed here"
	end

	syn clear
	setl modifiable
	let pos_save = getpos('.')
	sil %delete _

	syn match MarksPipe /─/
	syn match MarksPipe /└/
	syn match MarksPipe /├/

	let i = 1
	let b:marks.table = {}
	for [path, marks] in items(s:group_marks_by_file(a:marks))

		call matchadd('MarksFile', '\v%'.i.'l.*')
		let line = s:prettify_path(path)
		call setline(i, line)
		let i += 1

		let k = 0
		let width = len(max(map(copy(marks), 'v:val["linenr"]')))
		for mark in sort(marks, {a, b -> a['linenr'] - b['linenr']})
			let b:marks.table[i] = mark
			let line = k == len(marks)-1 ? '└─ ' : '├─ '
			let line .= printf('%s', mark.letter)
			call matchadd('MarksMark', '\v%'.i.'l%'.(len(line)).'c')
			let line .= printf(' %'.width.'S', mark.linenr)
			call matchadd('MarksLineNr', '\v%'.i.'l\d+%'.(len(line)+1).'c')
			let line .= printf(' %s', trim(mark.line))
			call setline(i, line)
			let i += 1
			let k += 1
		endfo

	endfo

	call s:resize_window()
	call setpos('.', pos_save)
	setl nomodifiable

endf

" Show error message.
func! marks#err(fmt, ...)
	echohl WarningMsg | echom call('printf', [a:fmt] + a:000)  | echohl None
endf

" Group marks by the file they belong to.
func! s:group_marks_by_file(marks)
	let groups = {}
	for mark in values(a:marks)
		if !has_key(groups, mark.file)
			let groups[mark.file] = []
		end
		call add(groups[mark.file], mark)
	endfo
	return groups
endf

" Resize the current window according to g:marks_max_winsize.
" That value is expected to be expressed in percentage.
func! s:resize_window()
	let max = float2nr(&lines * g:marks_max_winsize / 100)
	exec 'resize' min([line('$'), max])
endf

" Prettify the given path.
" Wherever possible, trim the current working directory.
func! s:prettify_path(path)
	let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
	return substitute(path, '\V\^'.$HOME, '~', '')
endf
