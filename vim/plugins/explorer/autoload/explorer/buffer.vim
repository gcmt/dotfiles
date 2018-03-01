
" Move the cursor to the first file in the buffer
func! explorer#buffer#goto_first_file()
	let offsets = get(b:explorer.map, 2, [0, 0])
	call cursor(2, offsets[0])
endf

" Move the cursor to the given file
func! explorer#buffer#goto_file(file, ...)
	call explorer#buffer#goto_first_file()
	let pattern = '\V\%' . col('.') . 'c' . a:file
	while search(pattern, 'Wc')
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

	" Extract offsets
	let offsets = s:parse_offsets()
	g;\v^//DIRED;delete _

	" Find the start of the file names column
	let offset = getline(1) =~ '\v^\s*total' ? len(getline(1)) : 0
	let start = get(offsets, 0, offset) - offset

	" Make offsets relative to each line
	let line = 2
	let b:explorer.map = {}
	for idx in range(0, len(offsets)-1, 2)
		let end = start + offsets[idx+1] - offsets[idx]
		let b:explorer.map[line] = [start, end]
		let line += 1
	endfor

	" Colors
	if !empty(g:explorer_details_color)
		exec 'syn match' g:explorer_details_color '/\v^\s*total.*/'
		exec 'syn match' g:explorer_details_color '/\v.%<'.start.'c/'
		exec 'syn match' g:explorer_details_color '/\v-\>\s\/.*/'
	end
	if !empty(g:explorer_dirs_color)
		exec 'syn match' g:explorer_dirs_color '/\v%'.start.'c[^/]+\/$/'
	end
	if !empty(g:explorer_links_color)
		exec 'syn match' g:explorer_links_color '/\v%'.start.'c.*\ze-\>\s\//'
	end

	" Set the statusline
	let command = substitute(command, '\v\s*--dired', '', '')
	let path = substitute(fnamemodify(a:path, ":p:~"), '\v/$', '', '')
	let stl = " " . command . " " . path . "%=explorer "
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
