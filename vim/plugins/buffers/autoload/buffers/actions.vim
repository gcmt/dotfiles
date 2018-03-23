
func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf

func! buffers#actions#edit(cmd) abort
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

func! buffers#actions#delete(cmd) abort
	let bufnr = get(b:buffers.table, line('.'), -1)
	if bufnr == -1
		return
	end
	if bufnr == b:buffers.current
		return s:err("Can't delete the current buffer")
	end
	try
		exec a:cmd bufnr
	catch /E.*/
		return s:err(matchstr(v:exception, '\vE\d+:.*'))
	endtry
	call buffers#render()
endf
