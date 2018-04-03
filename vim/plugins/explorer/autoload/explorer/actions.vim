
" explorer#actions#goto({path:string}) -> 0
" Move the cursor to the line with the given {path}.
" If not found, the parent directory is looked for, and so on..
func! explorer#actions#goto(path)
	if a:path == '/'
		return 0
	end
	for [line, entry] in items(b:explorer.map)
		if a:path == entry.path
			exec line
			norm! 0
			return 1
		end
	endfo
	return explorer#actions#goto(fnamemodify(a:path, ':h'))
endf

" Show file info (details that are returned by ls -l)
func! explorer#actions#show_info()
	let entry = get(b:explorer.map, line('.'), {})
	if empty(entry)
		return
	end
	echo entry.node.info
endf

" Close the current directory.
func! explorer#actions#close_dir() abort
	let entry = get(b:explorer.map, line('.'), {})
	if empty(entry) || empty(entry.node.parent) || empty(entry.node.parent.parent)
		return
	end
	let entry.node.parent.content = []
	call b:explorer.tree.render()
	call explorer#actions#goto(entry.node.parent.path)
endf

" Move root up one directory.
func! explorer#actions#up_root() abort
	let current = b:explorer.tree.path
	let parent = fnamemodify(b:explorer.tree.path, ':h')
	let root = g:explorer#tree#node.new(parent)
	if !root.get_content()
		return explorer#err('Could not retrieve content for ' . root.path)
	end
	let b:explorer.tree = root
	call b:explorer.tree.render()
	call explorer#actions#goto(current)
endf

" Set the current directory as root.
func! explorer#actions#set_root() abort
	let entry = get(b:explorer.map, line('.'), {})
	if empty(entry)
		return
	end
	if !isdirectory(entry.path)
		return explorer#err('Not a directory')
	end
	let root = g:explorer#tree#node.new(entry.path)
	if !root.get_content()
		return explorer#err('Could not retrieve content for ' . root.path)
	end
	let b:explorer.tree = root
	call b:explorer.tree.render()
	" Move the cursor to the first visible file (hidden files might not be visible)
	for node in root.content
		if explorer#actions#goto(node.path)
			break
		end
	endfo
endf

" Enter directory or edit file
func! explorer#actions#enter_or_edit() abort
	let entry = get(b:explorer.map, line('.'), {})
	if empty(entry)
		return
	end
	if isdirectory(entry.path)
		if !entry.node.get_content()
			return explorer#err('Could not retrieve content for ' . entry.node.path)
		end
		call b:explorer.tree.render()
		call explorer#actions#goto(entry.path)
		if !empty(entry.node.content)
			" Move the cursor to the first visible file (hidden files might not be visible)
			for node in entry.node.content
				if explorer#actions#goto(node.path)
					break
				end
			endfo
		end
	else
		let current = b:explorer.current
		exec 'edit' fnameescape(entry.path)
		let @# = buflisted(current) ? current : bufnr('%')
	end
endf

" Open current file in a preview window.
func! explorer#actions#preview() abort
	let entry = get(b:explorer.map, line('.'), {})
	if empty(entry)
		return
	end
	if isdirectory(entry.path)
		return explorer#err('Not a file')
	end
	keepa exec 'pedit' fnameescape(entry.path)
endf

" Create a new file in the current root directory.
" Intermediate directories are created as necessary.
func! explorer#actions#create_file() abort
	let file = input("New file: ") | redraw
	if empty(file)
		return
	end
	let dir = fnamemodify(file, ':h')
	let path = explorer#path#join(b:explorer.tree.path, dir)
	if !isdirectory(path)
		call mkdir(path, 'p')
		echo printf("Created intermediate directory '%s'", dir)
	end
	let path = explorer#path#join(b:explorer.tree.path, file)
	if filereadable(path)
		return explorer#err(printf("Cannot create file '%s': File exists", file))
	end
	exec "edit" fnameescape(path)
endf

" Create a new directory in the current root dorectory.
" Intermediate directories are created as necessary.
func! explorer#actions#create_directory() abort
	let dir = input("New directory: ") | redraw
	if empty(dir)
		return
	end
	let path = explorer#path#join(b:explorer.tree.path, dir)
	if isdirectory(path)
		return explorer#err(printf("Directory '%s' already exists", dir))
	end
	if filereadable(path)
		return explorer#err(printf("Cannot create directory '%s': File exists", dir))
	end
	call mkdir(path, 'p')
	echo printf("Created directory '%s'", dir)
	if !b:explorer.tree.get_content()
		return explorer#err('Could not retrieve content for ' . b:explorer.tree.path)
	end
	call b:explorer.tree.render()
	call explorer#actions#goto(path)
endf

func! explorer#actions#rename() abort
	let entry = get(b:explorer.map, line('.'), {})
	if empty(entry)
		return
	end
	if bufnr(entry.path) != -1 && getbufvar(bufnr(entry.path), '&mod')
		return explorer#err('File is open and contain changes')
	end
	let name = input(printf("Rename '%s' to: ", fnamemodify(entry.path, ':~'))) | redraw
	if empty(name)
		return
	end
	redraw
	let to = explorer#path#join(entry.node.parent.path, name)
 	if isdirectory(to) || filereadable(to)
		echo printf("The file '%s' already exists and it will be overwritten. Are you sure? [yn] ", fnamemodify(to, ':~'))
		if nr2char(getchar()) !~ 'y'
			return
		end
		redraw
	end
	if rename(entry.path, to) != 0
		return explorer#err("Operation failed")
	end
	if bufnr(entry.path) != -1
		exec 'split' fnameescape(to)
		close
		if bufnr(@#) == bufnr(entry.path)
			let @# = bufnr(to)
		end
		if b:explorer.current == bufnr(entry.path)
			let b:explorer.current = bufnr(to)
		end
		if b:explorer.alt == bufnr(entry.path)
			let b:explorer.alt = bufnr(to)
		end
		sil! exec 'bwipe' entry.path
	end
	if !entry.node.parent.get_content()
		return explorer#err('Could not retrieve content for ' . entry.node.parent.path)
	end
	call b:explorer.tree.render()
	call explorer#actions#goto(to)
endf

" Delete the current file or directory.
func! explorer#actions#delete() abort
	let entry = get(b:explorer.map, line('.'), {})
	if empty(entry)
		return
	end
	echo printf("The file '%s' will be deleted. Are you sure? [yn] ", fnamemodify(entry.path, ':~'))
	if nr2char(getchar()) !~ 'y'
		return
	end
	redraw
	if delete(entry.path, 'rf') != 0
		return explorer#err("Operation failed")
	else
		sil! exec 'bwipe' entry.path
		if !entry.node.parent.get_content()
			return explorer#err('Could not retrieve content for ' . entry.node.parent.path)
		end
		call b:explorer.tree.render()
	end
endf

" Show/hide hidden files.
func! explorer#actions#toggle_hidden_files()
	let g:explorer_hidden_files = 1 - g:explorer_hidden_files
	call b:explorer.tree.render()
endf

" Add bookmark (requires the 'bookmarks' plugin).
func! explorer#actions#bookmarks_set(mark)
	if !get(g:, 'loaded_bookmarks')
		return explorer#err("Bookmarks not available")
	end
	let entry = get(b:explorer.map, line('.'), {})
	if !empty(entry)
		call bookmarks#set(a:mark, entry.path)
	end
endf

" Show very basic help.
func! explorer#actions#help()
	let mappings = sort(filter(split(execute('nmap'), "\n"), {-> v:val =~ '\vexplorer#'}))
	call map(mappings, {-> substitute(v:val, '\V\(\^n  \|*@:call explorer#\(actions\|buffer\)#\|<CR>\$\)', '', 'g')})
	echo join(mappings, "\n")
endf
