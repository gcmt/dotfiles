
" Extract the file name at the given line
func! explorer#actions#get_file_at(nr)
	let offsets = get(b:explorer.map, a:nr, [])
	if empty(offsets)
		return ""
	end
	return strpart(getline(a:nr), offsets[0]-1, offsets[1] - offsets[0])
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

" Show/hide hidden files
func! explorer#actions#toggle_hidden_files()
	let g:explorer_hidden_files = 1 - g:explorer_hidden_files
	call explorer#buffer#render(b:explorer.dir)
endf
