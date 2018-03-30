
nnoremap <silent> <buffer> q :close<cr>

nnoremap <silent> <buffer> <enter> :call <sid>jump('')<cr>zz
nnoremap <silent> <buffer> <c-j> :call <sid>jump('')<cr>zz
nnoremap <silent> <buffer> l :call <sid>jump('')<cr>zz

" Jump to the current mark.
func! s:jump(mode) abort
	let mark = get(b:marks.table, line('.'), {})
	if !empty(mark)
		close
		exec 'norm! `' . mark.letter
		norm! zz
	end
endf

nnoremap <silent> <buffer> dd :call <sid>delete()<cr>

" Delete the current mark.
func! s:delete() abort
	let mark = get(b:marks.table, line('.'), {})
	if !empty(mark)
		wincmd p
		exec 'delmarks' mark.letter
		let marks = marks#marks()
		wincmd p
		call marks#render(marks)
	end
	if empty(b:marks.table)
		close
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
