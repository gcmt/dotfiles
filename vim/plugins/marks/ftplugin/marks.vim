
nnoremap <silent> <buffer> q :call <sid>close()<cr>

nnoremap <silent> <buffer> <enter> :<c-u>call <sid>jump()<cr>
nnoremap <silent> <buffer> <c-j> :<c-u>call <sid>jump()<cr>
nnoremap <silent> <buffer> l :<c-u>call <sid>jump()<cr>
nnoremap <silent> <buffer> s :<c-u>call <sid>jump('split')<cr>
nnoremap <silent> <buffer> v :<c-u>call <sid>jump('vsplit')<cr>
nnoremap <silent> <buffer> t :<c-u>call <sid>jump('tab')<cr>

" Jump to the current mark.
func! s:jump(...) abort
	let mark = get(b:marks.table, line('.'), {})
	if empty(mark)
		return
	end
	call s:close()
	let mode = a:0 > 0 ? a:1 : ''
	if mode =~ '\vv?split$'
		exec (v:count > 0 ? v:count : '') mode
	elseif mode == 'tab'
		exec (v:count > 0 ? v:count : '') 'tab split'
	end
	exec 'norm! `' . mark.letter
	norm! zz
endf

nnoremap <silent> <buffer> dd :call <sid>delete()<cr>

" Delete the current mark.
func! s:delete() abort
	let from_winnr = b:marks.from_winnr
	let mark = get(b:marks.table, line('.'), {})
	if empty(mark)
		return
	end
	exec from_winnr 'wincmd w'
	exec 'delmarks' mark.letter
	let marks = marks#marks()
	call s:focus()
	call marks#render(marks)
	if empty(b:marks.table)
		call s:close()
	end
endf

nnoremap <silent> <buffer> c :<c-u>call <sid>show_context()<cr>

" Show the current mark context.
func! s:show_context()
	let mark = get(b:marks.table, line('.'), {})
	if empty(mark)
		return
	end
	let start = max([mark.linenr - v:count1, 1])
	let end = mark.linenr + v:count1
	echo join(getbufline(mark.file, start, end), "\n")
endf

" Close marks window.
func! s:close()
	if s:focus()
		let from_winnr = b:marks.from_winnr
		close
		exec from_winnr 'wincmd w'
		return 1
	end
	return 0
endf

" focus marks window.
func! s:focus()
	sil exec bufwinnr(g:marks#bufname) 'wincmd w'
	return has_key(b:, 'marks')
endf
