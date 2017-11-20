
fun! flow#javascript#space()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return exists('g:loaded_pairs') ? pairs#space() : ' '
	end
	let before = flow#before()
	if before =~ '\v^\s*(for|while|if)$' || before =~ '\v^\s+}\selse\sif$'
		return " () {\<cr>}\<esc>k^f(a"
	end
	if before =~ '\v^\s*}\scatch$'
		return " (err) {\<cr>}\<esc>O"
	end
	if before =~ '\v^\s*(try|finally)$'
		return " {\<cr>}\<esc>O"
	end
	return exists('g:loaded_pairs') ? pairs#space() : ' '
endf

fun! flow#javascript#outward_parenthesis()
	if g:flow_disabled || flow#inside('String', 'Comment') || flow#indent('.') < flow#indent(line('.')+1)
		return exists('g:loaded_pairs') ? pairs#insert('(') : '('
	end
	let before = flow#before()
	let after = flow#after()
	if before =~ '\v<function(\*)?\s?\w*$' && after !~ '\v^\s*\{'
		let space = before =~ '\v<function(\*)?\s\w*$' ? '' : ' '
		return "" . space . "(\<esc>m`a) {\<cr>}\<esc>k``a"
	end
	return exists('g:loaded_pairs') ? pairs#insert('(') : '('
endf

fun! flow#javascript#colon()
	if g:flow_disabled || flow#inside('Comment')
		return ':'
	end
	if flow#before() =~ '\v\S$'
		return ': '
	end
	return ':'
endf

fun! flow#javascript#newline()
	if g:flow_disabled || flow#inside('Comment')
		return "\<esc>o"
	end
	let line = getline('.')
	let prevline = getline(line('.')-1)
	if line !~ '\v^\s*$' && line !~ '\v[,;+}]$' && prevline =~ '\v[\[({,]$'
		call setline(line('.'), substitute(line, '\v\s*$', ',', ''))
		return "\<esc>o"
	end
	if line =~ '\v\s+}$'
		call cursor('.', 1)
		let pos = searchpairpos('{', '', '}', 'nb')
		if pos != [0, 0] && getline(pos[0]) =~ '\v^\s+[^=({]+:'
			call setline(line('.'), substitute(line, '\v\s*$', ',', ''))
			return "\<esc>o"
		end
	end
	let nextline = getline(line(".")+1)
	if line !~ '\v^\s*$' && line !~ '\v[;,+{\[]\s*$' && nextline !~ '\v^\s*\.'
		call setline(line('.'), substitute(line, '\v\s*$', ';', ''))
		return "\<esc>o"
	end
	return "\<esc>o"
endf
