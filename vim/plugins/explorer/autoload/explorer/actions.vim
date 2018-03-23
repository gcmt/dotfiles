
" Extract the file name at the given line
func! s:file_at(linenr)
	let offsets = get(b:explorer.map, a:linenr, [])
	if empty(offsets)
		return ""
	end
	return strpart(getline(a:linenr), offsets[0]-1, offsets[1] - offsets[0])
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
	let file = s:file_at(line('.'))
	if empty(file)
		return
	end
	let path = explorer#path#join(b:explorer.dir, file)
	if isdirectory(path)
		call explorer#buffer#render(path)
		call explorer#buffer#goto_first_file()
	else
		let current = b:explorer.current
		exec 'edit' fnameescape(path)
		let @# = buflisted(current) ? current : bufnr('%')
	end
endf

" Create a new file in the current directory.
" Intermediate directories are created as necessary.
func! explorer#actions#create_file() abort
	let file = input("New file: ") | redraw
	if empty(file)
		return
	end
	let dir = fnamemodify(file, ':h')
	let path = explorer#path#join(b:explorer.dir, dir)
	if !isdirectory(path)
		call mkdir(path, 'p')
		echo printf("Created intermediate directory '%s'", dir)
	end
	let path = explorer#path#join(b:explorer.dir, file)
	if filereadable(path)
		return explorer#err(printf("Cannot create file '%s': File exists", file))
	end
	exec "edit" fnameescape(path)
endf

" Create a new directory in the current one.
" Intermediate directories are created as necessary.
func! explorer#actions#create_directory() abort
	let dir = input("New directory: ") | redraw
	if empty(dir)
		return
	end
	let path = explorer#path#join(b:explorer.dir, dir)
	if isdirectory(path)
		return explorer#err(printf("Directory '%s' already exists", dir))
	end
	if filereadable(path)
		return explorer#err(printf("Cannot create directory '%s': File exists", dir))
	end
	call mkdir(path, 'p')
	echo printf("Created directory '%s'", dir)
	call explorer#buffer#render(b:explorer.dir)
	call explorer#buffer#goto_file(split(dir, '/')[0])
endf

" Delete the current file or directory
func! explorer#actions#delete() abort
	let file = s:file_at(line('.'))
	if empty(file)
		return
	end
	let path = explorer#path#join(b:explorer.dir, file)
	echo printf("Deleting %s... Are you sure? [yn] ", fnamemodify(path, ':~'))
	if nr2char(getchar()) =~ 'y'
		call delete(path, 'rf')
		sil! exec 'bwipe' path
		call explorer#buffer#render(b:explorer.dir)
	end
	redraw | echo
endf

" Show/hide hidden files
func! explorer#actions#toggle_hidden_files()
	let g:explorer_hidden_files = 1 - g:explorer_hidden_files
	call explorer#buffer#render(b:explorer.dir)
endf

" Mark the current file/directory (requires the 'bookmarks' plugin)
func! explorer#actions#set_mark(mark)
	if !get(g:, 'loaded_bookmarks')
		return explorer#err("Bookmarks not available")
	end
	let file = s:file_at(line('.'))
	if !empty(file)
		let path = explorer#path#join(b:explorer.dir, file)
		call bookmarks#set(a:mark, path)
	end
endf
