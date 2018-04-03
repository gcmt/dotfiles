
" s:selected_node() -> dict
" Return the node on the current line.
func! s:selected_node()
	return get(b:explorer.map, line('.'), {})
endf

" explorer#actions#goto({path:string}) -> 0
" Move the cursor to the line with the given {path}.
" If not found, the parent directory is looked for, and so on..
func! explorer#actions#goto(path)
	if a:path == '/'
		return 0
	end
	for [line, node] in items(b:explorer.map)
		if a:path == node.path
			exec line
			norm! 0
			return 1
		end
	endfo
	return explorer#actions#goto(fnamemodify(a:path, ':h'))
endf

" Show file info (details that are returned by ls -l)
func! explorer#actions#show_info()
	let node = s:selected_node()
	if empty(node)
		return
	end
	echo node.info
endf

" Close the current directory.
func! explorer#actions#close_dir() abort
	let node = s:selected_node()
	if empty(node) || empty(node.parent) || empty(node.parent.parent)
		return
	end
	let node.parent.content = []
	call b:explorer.tree.render()
	call explorer#actions#goto(node.parent.path)
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
	let node = s:selected_node()
	if empty(node)
		return
	end
	if !isdirectory(node.path)
		return explorer#err('Not a directory')
	end
	if empty(node.content) && !node.get_content()
		return explorer#err('Could not retrieve content for ' . node.path)
	end
	call node.render()
	let b:explorer.tree = node
	" Move the cursor to the first visible file (hidden files might not be visible)
	for node in node.content
		if explorer#actions#goto(node.path)
			break
		end
	endfo
endf

" Enter directory or edit file
func! explorer#actions#enter_or_edit() abort
	let node = s:selected_node()
	if empty(node)
		return
	end
	if isdirectory(node.path)
		if !node.get_content()
			return explorer#err('Could not retrieve content for ' . node.path)
		end
		call b:explorer.tree.render()
		call explorer#actions#goto(node.path)
		if !empty(node.content)
			" Move the cursor to the first visible file (hidden files might not be visible)
			for node in node.content
				if explorer#actions#goto(node.path)
					break
				end
			endfo
		end
	else
		let current = b:explorer.current
		exec 'edit' fnameescape(node.path)
		let @# = buflisted(current) ? current : bufnr('%')
	end
endf

" Open current file in a preview window.
func! explorer#actions#preview() abort
	let node = s:selected_node()
	if empty(node)
		return
	end
	if isdirectory(node.path)
		return explorer#err('Not a file')
	end
	keepa exec 'pedit' fnameescape(node.path)
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
	let node = s:selected_node()
	if empty(node)
		return
	end
	if bufnr(node.path) != -1 && getbufvar(bufnr(node.path), '&mod')
		return explorer#err('File is open and contain changes')
	end
	let name = input(printf("Rename '%s' to: ", fnamemodify(node.path, ':~'))) | redraw
	if empty(name)
		return
	end
	redraw
	let to = explorer#path#join(node.parent.path, name)
 	if isdirectory(to) || filereadable(to)
		echo printf("The file '%s' already exists and it will be overwritten. Are you sure? [yn] ", fnamemodify(to, ':~'))
		if nr2char(getchar()) !~ 'y'
			return
		end
		redraw
	end
	if rename(node.path, to) != 0
		return explorer#err("Operation failed")
	end
	if bufnr(node.path) != -1
		exec 'split' fnameescape(to)
		close
		if bufnr(@#) == bufnr(node.path)
			let @# = bufnr(to)
		end
		if b:explorer.current == bufnr(node.path)
			let b:explorer.current = bufnr(to)
		end
		if b:explorer.alt == bufnr(node.path)
			let b:explorer.alt = bufnr(to)
		end
		sil! exec 'bwipe' node.path
	end
	if !node.parent.get_content()
		return explorer#err('Could not retrieve content for ' . node.parent.path)
	end
	call b:explorer.tree.render()
	call explorer#actions#goto(to)
endf

" Delete the current file or directory.
func! explorer#actions#delete() abort
	let node = s:selected_node()
	if empty(node)
		return
	end
	echo printf("The file '%s' will be deleted. Are you sure? [yn] ", fnamemodify(node.path, ':~'))
	if nr2char(getchar()) !~ 'y'
		return
	end
	redraw
	if delete(node.path, 'rf') != 0
		return explorer#err("Operation failed")
	else
		sil! exec 'bwipe' node.path
		if !node.parent.get_content()
			return explorer#err('Could not retrieve content for ' . node.parent.path)
		end
		call b:explorer.tree.render()
	end
endf

" Show/hide hidden files.
func! explorer#actions#toggle_hidden_files()
	let g:explorer_hidden_files = 1 - g:explorer_hidden_files
	let current = s:selected_node()
	call b:explorer.tree.render()
	if !empty(current)
		call explorer#actions#goto(current.path)
	end
endf

" Add bookmark (requires the 'bookmarks' plugin).
func! explorer#actions#bookmarks_set(mark)
	if !get(g:, 'loaded_bookmarks')
		return explorer#err("Bookmarks not available")
	end
	let node = s:selected_node()
	if !empty(node)
		call bookmarks#set(a:mark, node.path)
	end
endf

" Show very basic help.
func! explorer#actions#help()
	let mappings = sort(filter(split(execute('nmap'), "\n"), {-> v:val =~ '\vexplorer#'}))
	call map(mappings, {-> substitute(v:val, '\V\(\^n  \|*@:call explorer#\(actions\|buffer\)#\|<CR>\$\)', '', 'g')})
	echo join(mappings, "\n")
endf
