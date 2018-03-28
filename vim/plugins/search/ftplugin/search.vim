
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
	call cursor(pos)
	setl cursorline
	norm! zz
endf
