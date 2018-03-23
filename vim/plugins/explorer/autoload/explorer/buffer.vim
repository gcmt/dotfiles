
" Move the cursor to the first file in the buffer
func! explorer#buffer#goto_first_file()
	let offsets = get(b:explorer.map, 2, [0, 0])
	call cursor(2, offsets[0])
endf

" Move the cursor to the last file in the buffer
func! explorer#buffer#goto_last_file()
	let offsets = get(b:explorer.map, line('$'), [0, 0])
	call cursor(line('$'), offsets[0])
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

	let retain_position = a:path == get(b:explorer, 'dir', '')

	if retain_position
		let line_save = getline('.')
		let cursor_save = getpos('.')
	end

	syntax clear
	setl modifiable

	let command = s:ls_command()
	exec "%!" . command shellescape(a:path)
	if v:shell_error
		return
	end

	let offsets = s:parse_offsets()
	g;\v^//DIRED;delete _

	let offset = s:files_offset(offsets)

	let b:explorer.dir = a:path
	let b:explorer.map = s:build_map(offsets, offset)

	call s:do_highlight(offset)

	" Set the statusline
	let command = substitute(command, '\v\s*--dired', '', '')
	let command = substitute(command, '\v\s*--group-directories-first', '', '')
	let path = substitute(fnamemodify(a:path, ":p:~"), '\v/$', '', '')
	let stl = " " . command . " " . path . "%=explorer "
	call setwinvar(0, "&stl", stl)

	if retain_position
		if !search('\V\^' . substitute(line_save, '\v\s+', '\\s\\+', 'g'))
			exec cursor_save[1]
		end
		call cursor(line('.'), cursor_save[2])
	end

	setl nomodifiable

endf

" Find the start of the file names column.
func! s:files_offset(offsets)
	let offset = getline(1) =~ '\v^\s*total' ? len(getline(1)) : 0
	return get(a:offsets, 0, offset) - offset
endf

" Map each line with the start/end offsets of the file on the line.
func! s:build_map(offsets, start)
	let map = {}
	let line = 2
	for idx in range(0, len(a:offsets)-1, 2)
		let end = a:start + a:offsets[idx+1] - a:offsets[idx]
		let map[line] = [a:start, end]
		let line += 1
	endfor
	return map
endf

" Highlight things with different colors.
" The only argument 'offset' is the column where file names start.
func! s:do_highlight(offset)
	if !empty(g:explorer_details_color)
		exec 'syn match' g:explorer_details_color '/\v^\s*total.*/'
		exec 'syn match' g:explorer_details_color '/\v.%<'.a:offset.'c/'
		exec 'syn match' g:explorer_details_color '/\v-\>\s\/.*/'
	end
	if !empty(g:explorer_dirs_color)
		exec 'syn match' g:explorer_dirs_color '/\v%'.a:offset.'c[^/]+\/$/'
	end
	if !empty(g:explorer_execs_color)
		exec 'syn match' g:explorer_execs_color '/\v%'.a:offset.'c[^/]+\*$/'
	end
	if !empty(g:explorer_links_color)
		exec 'syn match' g:explorer_links_color '/\v%'.a:offset.'c.*\ze-\>\s\//'
	end
endf

func! s:ls_command()
	let flags = "-lhFH"
	let flags .= g:explorer_hide_owner_and_group ? 'go' : ''
	let cols = g:explorer_auto_hide_owner_and_group
	let flags .= cols && winwidth(0) < cols && flags !~ 'go' ? 'go' : ''
	let flags .= g:explorer_hidden_files ? 'A' : ''
	let flags .= g:explorer_directories_first ? ' --group-directories-first' : ''
	return printf("ls %s --dired", flags)
endf

func! s:parse_offsets()
	let nr = search('\v^//DIRED//', 'n')
	let offsets = split(substitute(getline(nr), '\v^//DIRED//', '', ''), '\s')
	call map(offsets, {i, val -> str2nr(val)})
	return offsets
endf
