
func! flow#css#setup()
	" inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=flow#css#space()<cr>
	inoremap <silent> <buffer> { <c-]><c-g>u<c-r>=flow#css#brace()<cr>
	inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=flow#css#esco()<cr>
	inoremap <silent> <buffer> ( <c-]><c-g>u<c-r>=flow#css#paren()<cr>
endf

func! flow#css#esco()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return "\<esc>o"
	end
	let line = getline('.')
	if line =~ '\v\s+\S' && line !~ '\v[;{}]\s*$'
		return "\<esc>A;\<cr>"
	end
	return "\<esc>o"
endf

func! flow#css#paren()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return flow#common#paren()
	end
	let before = flow#before()
	if before =~ '\v^\s*\@mixin \w*$'
		return "(\<esc>m`a) {\<cr>}\<esc>k``a"
	end
	return flow#common#paren()
endf

func! flow#css#brace()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return flow#common#brace()
	end
	let space = flow#before() =~ '\v\s+$' ? '' : ' '
	return "" . space . "{\<cr>}\<esc>O"
endf

func! flow#css#space()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return flow#common#space()
	end
	let before = flow#before()
	if before =~ '\v^\s+[^@][-a-z]+$' || before =~ '\v^\$[-a-z]+'
		return ': '
	end
	return flow#common#space()
endf
