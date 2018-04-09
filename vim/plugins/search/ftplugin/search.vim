
nnoremap <silent> <buffer> q :close<cr>

nnoremap <silent> <buffer> l :call <sid>jump()<cr>
nnoremap <silent> <buffer> <cr> :call <sid>jump()<cr>
nnoremap <silent> <buffer> <c-j> :call <sid>jump()<cr>

func! s:jump()
	let ctx = b:search.ctx
	let pos = get(b:search.table, line('.'), [])
	if empty(pos)
		return
	end
	close
	norm! m'
	exec ctx.bufnr 'buffer'
	call cursor(pos)
	norm! zz
endf

nnoremap <silent> <buffer> c :<c-u>call <sid>show_context()<cr>

func! s:show_context()
	let ctx = b:search.ctx
	let entry = get(b:search.table, line('.'), [])
	if empty(entry)
		return
	end
	let start = max([entry[0] - v:count1, 1])
	let end = entry[0] + v:count1
	echo join(getbufline(ctx.bufnr, start, end), "\n")
endf

