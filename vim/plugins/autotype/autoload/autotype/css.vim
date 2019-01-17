
func! autotype#css#setup()
	" inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=autotype#css#space()<cr>
	inoremap <silent> <buffer> { <c-]><c-g>u<c-r>=autotype#css#outward_brace()<cr>
	inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=autotype#css#esc_o()<cr>
	inoremap <silent> <buffer> ( <c-]><c-g>u<c-r>=autotype#css#outward_parenthesis()<cr>
endf

func! autotype#css#esc_o()
	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return "\<esc>o"
	end
	let line = getline('.')
	if line =~ '\v\s+\S' && line !~ '\v[;{}]\s*$'
		return "\<esc>A;\<cr>"
	end
	return "\<esc>o"
endf

func! autotype#css#outward_parenthesis()
	let Paren = {-> exists('*pairs#insert_paren') ? pairs#insert_paren('(') : '('}
	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return Paren()
	end
	let before = autotype#before()
	if before =~ '\v^\s*\@mixin \w*$'
		return "(\<esc>m`a) {\<cr>}\<esc>k``a"
	end
	return Paren()
endf

func! autotype#css#outward_brace()
	let Brace = {-> exists('*pairs#insert_paren') ? pairs#insert_paren('{') : '{'}
	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return Brace()
	end
	let space = autotype#before() =~ '\v\s+$' ? '' : ' '
	return "" . space . "{\<cr>}\<esc>O"
endf

func! autotype#css#space()
	let Space = {-> exists('*pairs#space') ? pairs#space() : ' '}
	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return Space()
	end
	let before = autotype#before()
	if before =~ '\v^\s+[^@][-a-z]+$' || before =~ '\v^\$[-a-z]+'
		return ': '
	end
	return Space()
endf
