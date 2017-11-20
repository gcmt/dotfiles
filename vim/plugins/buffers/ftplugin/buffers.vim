
func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf

func! s:edit(cmd) abort
	let win = winnr()
	let bufnr = get(b:buffers.table, line('.'), -1)
	if bufnr == -1
		return
	end
	wincmd p
	exec win.'wincmd c'
	if bufnr == bufnr('%')
		return
	end
	if empty(bufname(bufnr))
		exec 'b' bufnr
	else
		exec a:cmd fnameescape(bufname(bufnr))
	end
endf

func! s:delete(cmd) abort
	let bufnr = get(b:buffers.table, line('.'), -1)
	if bufnr == -1
		return
	end
	if bufnr == b:buffers.current
		return s:err("Forbidden: can't delete the current buffer")
	end
	try
		exec a:cmd bufnr
	catch /E.*/
		return s:err(matchstr(v:exception, '\vE\d+:.*'))
	endtry
	let pos = getpos('.')
	call buffers#render_buffers()
	call setpos('.', pos)
endf

sil! nunmap vv

nnoremap <silent> <buffer> <enter> :call <sid>edit('edit')<cr>zz
nnoremap <silent> <buffer> <c-j> :call <sid>edit('edit')<cr>zz
nnoremap <silent> <buffer> l :call <sid>edit('edit')<cr>zz
nnoremap <silent> <buffer> e :call <sid>edit('edit')<cr>zz
nnoremap <silent> <buffer> o :call <sid>edit('edit')<cr>zz
nnoremap <silent> <buffer> t :call <sid>edit('tabedit')<cr>zz
nnoremap <silent> <buffer> s :call <sid>edit('split')<cr>zz
nnoremap <silent> <buffer> v :call <sid>edit('vsplit')<cr>zz

nnoremap <silent> <buffer> dd :call <sid>delete('bdelete')<cr>
nnoremap <silent> <buffer> d! :call <sid>delete('bdelete!')<cr>
nnoremap <silent> <buffer> ww :call <sid>delete('bwipe')<cr>
nnoremap <silent> <buffer> w! :call <sid>delete('bwipe!')<cr>
nnoremap <silent> <buffer> uu :call <sid>delete('bunload')<cr>
nnoremap <silent> <buffer> u! :call <sid>delete('bunload!')<cr>
