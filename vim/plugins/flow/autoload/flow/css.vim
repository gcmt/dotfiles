
fun! flow#css#newline()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return "\<esc>o"
	end
	let line = getline('.')
	if line =~ '\v\s+\S' && line !~ '\v[;{}]\s*$'
		return "\<esc>A;\<cr>"
	end
	return "\<esc>o"
endf

fun! flow#css#outward_parenthesis()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return exists('g:loaded_pairs') ? pairs#insert('(') : '('
	end
	let before = flow#before()
	if before =~ '\v^\s*\@mixin \w*$'
		return "(\<esc>m`a) {\<cr>}\<esc>k``a"
	end
	return exists('g:loaded_pairs') ? pairs#insert('(') : '('
endf

fun! flow#css#outward_brace()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return exists('g:loaded_pairs') ? pairs#insert('{') : '{'
	end
	let space = flow#before() =~ '\v\s+$' ? '' : ' '
	return "" . space . "{\<cr>}\<esc>O"
endf

fun! flow#css#space()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return exists('g:loaded_pairs') ? pairs#space() : ' '
	end
	let before = flow#before()
	if before =~ '\v^\s+[^@][-a-z]+$' || before =~ '\v^\$[-a-z]+'
		return ': '
	end
	return exists('g:loaded_pairs') ? pairs#space() : ' '
endf
