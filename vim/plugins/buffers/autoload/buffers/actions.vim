

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

	exec b:buffers.current_winnr 'wincmd w'
	exec bufwinnr(s:bufname) 'wincmd c'

	if bufnr == bufnr('%')
		return
	end

	let mode = a:0 ? a:1 : ''
	let map = {'tab': 'tab split', 'split': 'split', 'vsplit': 'vsplit'}

	if getbufvar(bufnr, '&bt') == 'terminal'
		sil exec get(map, mode, 'split')
		sil exec 'buffer' bufnr
	elseif empty(bufname(bufnr))
		sil exec get(map, mode, '')
		sil exec 'buffer' bufnr
	else
		sil exec get(map, mode, '')
		sil exec 'edit' fnameescape(bufname(bufnr))
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

	let winnr = b:buffers.current_winnr
	let close_win = 0

	while bufwinnr(bufnr) > -1
		exec bufwinnr(bufnr) 'wincmd w'
		let replacement = -1
		if buflisted(bufnr('#'))
			let replacement = bufnr('#')
		else
			for b in range(1, bufnr('$'))
				if buflisted(b) && b != bufnr
					let replacement = b
					break
				end
			endfo
		end
		if replacement >= 1
			sil exec 'buffer' replacement
		else
			enew
			let close_win = 1
		end
	endw

	exec winnr 'wincmd w'
	let current = bufnr('%')
	exec bufwinnr(s:bufname) 'wincmd w'
	let b:buffers['current_bufnr'] = current

	let cmd = a:cmd
	if getbufvar(bufnr, '&buftype') == 'terminal'
		let cmd = 'bwipe!'
	end

	try
		exec cmd bufnr
	catch /E.*/
		return s:err(matchstr(v:exception, '\vE\d+:.*'))
	endtry

	call s:render()

	if close_win
		close
	end

endf


" buffers#actions#toggle_all() -> 0
" Toggle visibility of unlisted buffers.
func! buffers#actions#toggle_unlisted()
	let b:buffers.all = 1 - b:buffers.all
	let selected = get(b:buffers.table, line('.'), -1)
	call s:render()
	for [line, bufnr] in items(b:buffers.table)
		if bufnr == selected
			call cursor(line, 1)
			break
		end
	endfor
endf


" buffers#open_explorer() -> 0
" Close the window and open the explorer instead.
func! buffers#actions#open_explorer()
	exec b:buffers.current_winnr 'wincmd w'
	exec bufwinnr(s:bufname) 'wincmd c'
	let cmd = exists(':Ranger') ? 'Ranger' : 'Explorer'
	exec cmd expand('%:p:h')
endf


" s:render() -> 0
" Render the buffers list in the current buffer and saves the current cursor
" position.
func! s:render()
	let line_save = getcurpos()[1]
	let b:buffers["table"] = buffers#render(bufnr('%'), b:buffers.all)
	exec line_save
endf


" s:err({msg:string}) -> 0
" Display a simple error message.
func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
