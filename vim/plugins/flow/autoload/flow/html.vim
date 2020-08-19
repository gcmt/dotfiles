
func! flow#html#setup()
	inoremap <silent> <buffer> ! <c-]><c-g>u<c-r>=flow#html#bang()<cr>
	inoremap <silent> <buffer> <c-j> <c-]><c-g>u<c-r>=flow#html#newline()<cr>
	inoremap <silent> <buffer> <enter> <c-]><c-g>u<c-r>=flow#html#newline()<cr>
endf

func! flow#html#newline()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return "\<cr>"
	end
	if flow#before() =~ '\V>\$' && flow#after() =~ '\V\^<'
		return "\<cr>\<esc>O\<tab>"
	end
	return "\<cr>"
endf

func! flow#html#bang()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return '!'
	end
	if getline('.') =~ '\v^\s*$' || flow#after() =~ '\v^\s*$'
		return "<!--  -->\<esc>bhi"
	end
	return '!'
endf
