
func! autotype#css#newline()
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
	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return get(g:, 'loaded_pairs', 0) ? pairs#insert('(') : '('
	end
	let before = autotype#before()
	if before =~ '\v^\s*\@mixin \w*$'
		return "(\<esc>m`a) {\<cr>}\<esc>k``a"
	end
	return get(g:, 'loaded_pairs', 0) ? pairs#insert('(') : '('
endf

func! autotype#css#outward_brace()
	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return get(g:, 'loaded_pairs', 0) ? pairs#insert('{') : '{'
	end
	let space = autotype#before() =~ '\v\s+$' ? '' : ' '
	return "" . space . "{\<cr>}\<esc>O"
endf

func! autotype#css#space()
	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return get(g:, 'loaded_pairs', 0) ? pairs#space() : ' '
	end
	let before = autotype#before()
	if before =~ '\v^\s+[^@][-a-z]+$' || before =~ '\v^\$[-a-z]+'
		return ': '
	end
	return get(g:, 'loaded_pairs', 0) ? pairs#space() : ' '
endf
