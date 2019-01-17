
func! autotype#html#setup()
	inoremap <silent> <buffer> ! <c-]><c-g>u<c-r>=autotype#html#bang()<cr>
	inoremap <silent> <buffer> <c-j> <c-]><c-g>u<c-r>=autotype#html#newline()<cr>
	inoremap <silent> <buffer> <enter> <c-]><c-g>u<c-r>=autotype#html#newline()<cr>
endf

func! autotype#html#newline()
	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return "\<cr>"
	end
	if '><' == get(autotype#before(1), -1, '') . get(autotype#after(1), 0, '')
		return "\<cr>\<esc>O\<tab>"
	end
	return "\<cr>"
endf

func! autotype#html#bang()
	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return '!'
	end
	if getline('.') =~ '\v^\s*$' || autotype#after() =~ '\v^\s*$'
		return "<!--  -->\<esc>bhi"
	end
	return '!'
endf
