
func! s:edit(cmd) abort
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
		call bookmarks#render_marks()
		call setpos('.', pos)
	end
endf

sil! nunmap vv

nnoremap <silent> <buffer> <enter> :call <sid>edit('edit')<cr>zz
nnoremap <silent> <buffer> <c-j> :call <sid>edit('edit')<cr>zz
nnoremap <silent> <buffer> l :call <sid>edit('edit')<cr>zz
nnoremap <silent> <buffer> o :call <sid>edit('edit')<cr>zz
nnoremap <silent> <buffer> e :call <sid>edit('edit')<cr>zz
nnoremap <silent> <buffer> t :call <sid>edit('tabedit')<cr>zz
nnoremap <silent> <buffer> s :call <sid>edit('split')<cr>zz
nnoremap <silent> <buffer> v :call <sid>edit('vsplit')<cr>zz
nnoremap <silent> <buffer> dd :call <sid>unset()<cr>
