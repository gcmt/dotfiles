
" Returns the column where files are displayed
func! explorer#buffer#files_column_start()
	let offset = getline(1) =~ '\v^\s*total' ? len(getline(1)) : 0
	return get(b:explorer.offsets, 0, offset) - offset
endf

" Move the cursor to the first file in the buffer
func! explorer#buffer#goto_first_file()
	let offset = get(b:explorer.offsets, 0, 0) + 1
	exec offset . "goto"
endf

" Move the cursor to the given file
func! explorer#buffer#goto_file(file, ...)
	call explorer#buffer#goto_first_file()
	let pattern = '\V\%' . col('.') . 'c' . a:file
	keepj norm! gg
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

	let b:explorer.map = {}
	let b:explorer.offsets = []
	let b:explorer.dir = a:path

	" Populate the buffer with the ls command output
	let flags = "-lhF"
	let flags = g:explorer_hidden_files ? flags.'A' : flags
	let flags = g:explorer_hide_group ? flags.'o' : flags
	let flags = g:explorer_hide_owner ? flags.'g' : flags
	let cmd = printf("ls %s --dired", flags)
	exec "%!" . cmd shellescape(a:path)
	if v:shell_error
		return
	end

	" Extract dired offsets
	let linenr = search('\v^//DIRED//', 'n')
	let offsets = split(substitute(getline(linenr), '\v^//DIRED//', '', ''), '\s')
	call map(offsets, {i, val -> str2nr(val)})
	let b:explorer.offsets = offsets
	g;\v^//DIRED;delete _

   " Map lines and offsets
	let line = 2
	for idx in range(0, len(offsets)-1, 2)
		let b:explorer.map[line] = [offsets[idx], offsets[idx+1]]
		let line += 1
	endfor

	" Highlight details in a different color
	let col = explorer#buffer#files_column_start()
	exec 'syn match ExplorerDetails /\v.%<' . col . 'c/'

	" Set the statusline
	let stl = " " . cmd . " " . fnamemodify(a:path, ":p:~") . "%=explorer "
	call setwinvar(0, "&stl", stl)

	setl nomodifiable

endf
