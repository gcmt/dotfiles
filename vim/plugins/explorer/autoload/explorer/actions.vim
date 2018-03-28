
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

func! explorer#actions#rename() abort
	let file = s:file_at(line('.'))
	if empty(file)
		return
	end
	let path = explorer#path#join(b:explorer.dir, file)
	if bufnr(path) != -1 && getbufvar(bufnr(path), '&mod')
		return explorer#err('File is open and contain changes')
	end
	let name = input(printf("Rename '%s' to: ", file)) | redraw
	if empty(name)
		return
	end
	redraw
	let to = explorer#path#join(b:explorer.dir, name)
 	if isdirectory(to) || filereadable(to)
		echo printf("The file '%s' already exists and it will be overwritten. Are you sure? [yn] ", fnamemodify(to, ':~'))
		if nr2char(getchar()) !~ 'y'
			return
		end
		redraw
	end
	if rename(path, to) != 0
		return explorer#err("Operation failed")
	else
		if bufnr(path) != -1
			exec 'split' fnameescape(to)
			close
			if bufnr(@#) == bufnr(path)
				let @# = bufnr(to)
			end
			if b:explorer.current == bufnr(path)
				let b:explorer.current = bufnr(to)
			end
			if b:explorer.alt == bufnr(path)
				let b:explorer.alt = bufnr(to)
			end
			sil! exec 'bwipe' path
		end
		call explorer#buffer#render(b:explorer.dir)
	end
	echo | redraw
endf

" Delete the current file or directory
func! explorer#actions#delete() abort
	let file = s:file_at(line('.'))
	if empty(file)
		return
	end
	let path = explorer#path#join(b:explorer.dir, file)
	echo printf("The file '%s' will be deleted. Are you sure? [yn] ", fnamemodify(path, ':~'))
	if nr2char(getchar()) !~ 'y'
		return
	end
	redraw
	if delete(path, 'rf') != 0
		return explorer#err("Operation failed")
	else
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

func! explorer#actions#help()
	let mappings = sort(filter(split(execute('nmap'), "\n"), {-> v:val =~ '\vexplorer#'}))
	call map(mappings, {-> substitute(v:val, '\V\(\^n  \|*@:call explorer#\(actions\|buffer\)#\|<CR>\$\)', '', 'g')})
	echo join(mappings, "\n")
endf
