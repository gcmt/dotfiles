
nnoremap <silent> <buffer> q :close<cr>

nnoremap <silent> <buffer> l :call <sid>jump()<cr>
nnoremap <silent> <buffer> <cr> :call <sid>jump()<cr>
nnoremap <silent> <buffer> <c-j> :call <sid>jump()<cr>

func! s:jump()
	let pos = get(b:search.table, line('.'), [])
	if empty(pos)
		return
	end
	close
	norm! m'
	call cursor(pos)
	setl cursorline
	norm! zz
endf

nnoremap <silent> <buffer> c :call <sid>show_context()<cr>

func! s:show_context() range
	let entry = get(b:search.table, line('.'), [])
	if empty(entry)
		return
	end
	let start = entry[0] - v:count1
	let end = entry[0] + v:count1
	echo join(getbufline(entry[2], start, end), "\n")
endf

