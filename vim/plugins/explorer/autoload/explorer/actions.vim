
" Extract the file name at the given line
func! explorer#actions#get_file_at(linenr)
	let offsets = get(b:explorer.map, a:linenr, [])
	if empty(offsets)
		return ""
	end
	exec (offsets[0]+1) . 'go'
	return strpart(getline(a:linenr), col('.')-1, offsets[1] - offsets[0])
endf

" Go to the parent directory
func! explorer#actions#up_dir() abort
	if b:explorer.dir == '/'
		return
	end
	let current = b:explorer.dir
	let parent = fnamemodify(current, ':h')
	call explorer#buffer#render(parent)
	call explorer#buffer#goto_file(fnamemodify(current, ':t'))
endf

" Enter directory or edit file
func! explorer#actions#enter_or_edit() abort
	let file = explorer#actions#get_file_at(line('.'))
	if empty(file)
		return
	end
	let path = b:explorer.dir . (b:explorer.dir == '/' ? file : '/' . file)
	if isdirectory(path)
      call explorer#buffer#render(path)
		call explorer#buffer#goto_first_file()
	else
		let current = b:explorer.current
		exec 'edit' fnameescape(path)
		let @# = buflisted(current) ? current : bufnr('%')
	end
endf

" Show/hide hidden files
func! explorer#actions#toggle_hidden_files()
	let g:explorer_hidden_files = 1 - g:explorer_hidden_files
	let current_line = getline('.')
	let cursor_save = getpos('.')
	call explorer#buffer#render(b:explorer.dir)
	if !search('\V\^' . substitute(current_line, '\v\s+', '\\s\\+', 'g'))
		exec cursor_save[1]
	end
	call setpos('.', [0, line('.'), cursor_save[2], 0])
endf
