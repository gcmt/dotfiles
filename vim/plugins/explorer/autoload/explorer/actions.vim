
" Go to the parent directory
func! explorer#actions#up_dir() abort
	if b:explorer.dir == '/'
		return
	end
	let current = b:explorer.dir
	let parent = fnamemodify(b:explorer.dir, ':h')
	call explorer#buffer#render(parent)
	call explorer#utils#set_cursor(current)
endf

" Enter directory or edit file
func! explorer#actions#enter_or_edit() abort
	let file = get(b:explorer.table, line('.'), '')
	if empty(file)
		return
	end
	let path = b:explorer.dir . (b:explorer.dir == '/' ? file : '/' . file)
	if isdirectory(path)
      call explorer#buffer#render(path)
		norm! gg
	else
		let current = b:explorer.current
		exec 'edit' fnameescape(path)
		let @# = buflisted(current) ? current : bufnr('%')
	end
endf

" Show/hide hidden files
func! explorer#actions#toggle_hidden_files()
	let g:explorer_hidden_files = 1 - g:explorer_hidden_files
	let line_save = getline('.')
	let linenr_save = line('.')
	call explorer#buffer#render(b:explorer.dir)
	if !search('\V\^' . substitute(line_save, '\v\s+', '\\s\\+', 'g'))
		exec linenr_save
	end
endf
