
" Returns the column where files are displayed
func! explorer#buffer#files_column_start()
	let offset = getline(1) =~ '\v^\s*total' ? len(getline(1)) : 0
	return get(b:explorer.offsets, 0, offset) - offset
endf

" Move the cursor to the first file in the buffer
func! explorer#buffer#goto_first_file()
	let offset = get(b:explorer.offsets, 0, 0) + 1
	exec offset . "go"
endf

" Move the cursor to the given file
func! explorer#buffer#goto_file(file, ...)
	call explorer#buffer#goto_first_file()
	let pattern = '\V\%' . col('.') . 'c' . a:file
	while search(pattern, 'W')
		let offsets = get(b:explorer.map, line('.'))
		if len(a:file) == offsets[1] - offsets[0]
			return
		end
	endw
endf

" Pupulate the explorer buffer with the output of the ls command
func! explorer#buffer#render(path) abort

	if &filetype != 'explorer'
		throw "Explorer: &filetype must be 'explorer'"
	end

	syntax clear
	setl modifiable

	let b:explorer.dir = a:path

	" Populate the buffer with the ls command output
	let command = s:ls_command()
	exec "%!" . command shellescape(a:path)
	if v:shell_error
		return
	end

	" Extract dired offsets
	let b:explorer.offsets = s:parse_offsets()
	g;\v^//DIRED;delete _

	" Map lines and offsets
	let line = 2
	let b:explorer.map = {}
	for idx in range(0, len(b:explorer.offsets)-1, 2)
		let b:explorer.map[line] = [b:explorer.offsets[idx], b:explorer.offsets[idx+1]]
		let line += 1
	endfor

	" Highlight details in a different color
	let col = explorer#buffer#files_column_start()
	exec 'syn match ExplorerDetails /\v.%<' . col . 'c/'

	" Set the statusline
	let stl = " " . command . " " . fnamemodify(a:path, ":p:~") . "%=explorer "
	call setwinvar(0, "&stl", stl)

	setl nomodifiable

endf

func! s:ls_command()
	let flags = "-lhF"
	let flags .= g:explorer_hide_owner_and_group ? 'go' : ''
	let columns = g:explorer_auto_hide_owner_and_group
	if columns && winwidth(0) < columns
		let flags .= flags =~ 'go' ? '' : 'go'
	end
	let flags .= g:explorer_hidden_files ? 'A' : ''
	return printf("ls %s --dired", flags)
endf

func! s:parse_offsets()
	let nr = search('\v^//DIRED//', 'n')
	let offsets = split(substitute(getline(nr), '\v^//DIRED//', '', ''), '\s')
	call map(offsets, {i, val -> str2nr(val)})
	return offsets
endf
