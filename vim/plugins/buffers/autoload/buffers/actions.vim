
let s:bufname = '__buffers__'

" buffers#actions#edit([{mode:string}]) -> 0
" Edit the buffer under cursor with the given {mode}. If no {mode} is given, the
" buffer will be edited in the current window, otherwise {mode} is expected to
" be one of (tab|split|vsplit).
func! buffers#actions#edit(...) abort
	let bufnr = get(b:buffers.table, line('.'), -1)
	if bufnr == -1
		return
	end
	exec b:buffers.winnr 'wincmd w'
	exec bufwinnr(s:bufname) 'wincmd c'
	if bufnr == bufnr('%')
		return
	end
	let mode = a:0 ? a:1 : ''
	let map = {'tab': 'tab split', 'split': 'split', 'vsplit': 'vsplit'}
	let default = getbufvar(bufnr, '&bt') == 'terminal' ? 'split' : ''
	sil exec get(map, mode, default)
	sil exec 'buffer' bufnr
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

" buffers#open_explorer() -> 0
" Close the window and open the explorer instead.
func! buffers#actions#open_explorer()
	exec b:buffers.winnr 'wincmd w'
	exec bufwinnr(s:bufname) 'wincmd c'
	let cmd = exists(':Ranger') ? 'Ranger' : 'Explorer'
	exec cmd expand('%:p:h')
endf

" s:err({msg:string}) -> 0
" Display a simple error message.
func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
