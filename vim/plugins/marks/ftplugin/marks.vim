
nnoremap <silent> <buffer> q :close<cr>

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
	close
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
