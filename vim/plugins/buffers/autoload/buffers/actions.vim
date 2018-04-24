
" buffers#actions#edit({cmd:string}) -> 0
" Edit the buffer under cursor with the given command {cmd}.
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

" buffers#actions#delete({cmd:string}) -> 0
" Delete/wipe/unload the buffer under cursor. {cmd} is expected to be one of
" (bdelete|bwipe|bunload).
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

" buffers#actions#toggle_all() -> 0
" Toggle visibility of unlisted buffers.
func! buffers#actions#toggle_unlisted()
	let b:buffers.all = 1 - b:buffers.all
	call buffers#render()
endf

" s:err({msg:string}) -> 0
" Display a simple error message.
func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
