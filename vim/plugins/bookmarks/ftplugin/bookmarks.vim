
func! s:jump(cmd) abort
	let win = winnr()
	let mark = get(b:bookmarks.table, line('.'), '')
	if !empty(mark)
		wincmd p
		exec win.'wincmd c'
		call bookmarks#jump(mark, a:cmd)
	end
endf

func! s:unset()
	let mark = get(b:bookmarks.table, line('.'), {})
	if !empty(mark)
		call bookmarks#unset(mark)
		let pos = getpos('.')
		call bookmarks#render()
		call setpos('.', pos)
	end
	if empty(bookmarks#marks())
		close
	end
endf

nnoremap <silent> <buffer> q :close<cr>
nnoremap <silent> <buffer> <enter> :call <sid>jump('edit')<cr>zz
nnoremap <silent> <buffer> <c-j> :call <sid>jump('edit')<cr>zz
nnoremap <silent> <buffer> l :call <sid>jump('edit')<cr>zz
nnoremap <silent> <buffer> dd :call <sid>unset()<cr>
