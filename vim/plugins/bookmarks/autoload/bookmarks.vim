
let s:marks = {}
let s:bufname = '__bookmarks__'

func bookmarks#unset(mark)
	call remove(s:marks, a:mark)
endf

func bookmarks#set(mark, target) abort
	if type(a:target) != v:t_string
		return s:err("Invalid target")
	end
	let mark = type(a:mark) == v:t_number ? nr2char(a:mark) : a:mark
	if mark == "\<esc>"
		return
	end
	if len(mark) != 1 || g:bookmarks_marks !~# mark
		return s:err("Invalid mark")
	end
	if index(values(s:marks), a:target) > -1
		" dont allow multiple marks for the same target
		let i = index(values(s:marks), a:target)
		call remove(s:marks, keys(s:marks)[i])
	end
	let s:marks[mark] = a:target
	echom '"'.s:prettify_path(a:target).'" marked with ['.mark.']'
endf

func bookmarks#jump(mark, ...) abort
	let cmd = a:0 ? a:1 : 'edit'
	let mark = type(a:mark) == v:t_number ? nr2char(a:mark) : a:mark
	if mark == "\<esc>"
		return
	end
	if len(mark) != 1 || g:bookmarks_marks !~# mark
		return s:err("Invalid mark")
	end
	let target = get(s:marks, mark, '')
	if empty(target)
		return s:err("Mark not set")
	end
	if isdirectory(target)
		exec 'Explorer' fnameescape(target)
	else
		exec 'edit' fnameescape(s:prettify_path(target))
	end
endf

func bookmarks#view() abort
	if bufwinnr(s:bufname) != -1
		return
	end
	if empty(s:marks)
		return s:err("No bookmarks found")
	end
	exec 'sil keepj keepa botright 1new' s:bufname
	let b:bookmarks = {'table': {}}
	setl filetype=bookmarks buftype=nofile bufhidden=delete nobuflisted
	setl noundofile nobackup noswapfile nospell
	setl nowrap nonumber norelativenumber nolist textwidth=0
	setl cursorline nocursorcolumn colorcolumn=0
	setl stl=\ :Bookmarks
	call bookmarks#render()
	norm! ggl
endf

func bookmarks#render()

	if &filetype != 'bookmarks'
		throw "Bookmarks: not allowed here"
	end

	syntax clear
	setl modifiable
	sil %delete _

	let marks = sort(items(s:marks))

	call s:resize_window(len(marks))

	syn match BookmarksDim /\v(\[|\])/

	let text = []
	let b:bookmarks.table = {}
	for i in range(1, len(marks))

		let [mark, target] = marks[i-1]
		let b:bookmarks.table[i] = mark

		let line = ''

		exec 'syn match BookmarksMark /\v%'.i.'l%'.(2).'c./'
		let line .= '['.mark.'] '

		let tail = fnamemodify(target, ':t')
		let group = isdirectory(target) ? 'BookmarksDir' : 'BookmarksFile'
		exec 'syn match '.group.' /\v%'.i.'l%>'.(len(line)).'c.*%<'.(len(line)+len(tail)+2).'c/'
		let line .= tail

		let target = s:prettify_path(target)
		exec 'syn match BookmarksDim /\v%'.i.'l%>'.(len(line)).'c.*/'
		let line .= ' ' . target

		call add(text, line)

	endfor

	if empty(marks)
		call add(text, "No bookmarks found..")
	end

	call setline(1, text)
	setl nomodifiable

endf

func s:resize_window(entries_num)
	let max = float2nr(&lines * g:bookmarks_max_winsize / 100)
	exec 'resize' min([a:entries_num, max])
endf

func s:prettify_path(path)
	let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
	return substitute(path, '\V\^'.$HOME, '~', '')
endf

func s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
