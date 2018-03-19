
fun! autotype#php#space()
	let Space = {-> exists('*pairs#space') ? pairs#space() : ' '}
	if g:autotype_disabled || autotype#inside('String', 'Comment') || indent(line('.')) < indent(line('.')+1)
		return Space()
	end
	let before = autotype#before()
	let after = autotype#after()
	if before =~ '\v^\s*(for|foreach|while|if|switch)$' || before =~ '\v}\s*(elseif|catch)$'
		return " () {\<cr>}\<esc>k$F(a"
	end
	if before =~ '\v\s*(try|finally|else)$'
		return " {\<cr>}\<esc>O"
	end
	if before =~ '\v\s*do$'
		return " {\<cr>} while ();\<esc>O"
	end
	if before =~ '\v<class \w+$'
		return " {\<cr>}\<esc>O"
	end
	return Space()
endf

fun! autotype#php#outward_parenthesis()
	let Paren = {-> exists('*pairs#insert_paren') ? pairs#insert_paren('(') : '('}
	if g:autotype_disabled || autotype#inside('String', 'Comment') || indent(line('.')) < indent(line('.')+1)
		return Paren()
	end
	let before = autotype#before()
	let after = autotype#after()
	if before =~ '\v<function \w*$' && after !~ '\v^\s*\{'
		return "(\<esc>m`a) {\<cr>}\<esc>k``a"
	end
	return Paren()
endf

fun! autotype#php#dot()
	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return '.'
	end
	if autotype#before() =~ '\v\w$'
		return "->"
	end
	return '.'
endf

fun! autotype#php#newline()
	if g:autotype_disabled || autotype#inside('Comment')
		return "\<esc>o"
	end
	let line = getline('.')
	let prevline = getline(line('.')-1)
	if line =~ '\v^\s*(case|default)>' && line !~ '\v:$'
		return "\<esc>A:\<cr>"
	end
	if line !~ '\v^\s*$' && line !~ '\v[,;]$' && prevline =~ '\v[\[(,]\s*$'
		return "\<esc>A,\<cr>"
	end
	let nextline = getline(line(".")+1)
	if line !~ '\v[;,+{}\[]\s*$' && line !~ '\v^\s*$' && nextline !~ '\v^\s*\.'
		return "\<esc>A;\<cr>"
	end
	return "\<esc>o"
endf

fun! autotype#php#colon()
	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return ':'
	end
	let before = autotype#before()
	let after = autotype#after()
	if after =~ '\v^\)' && before =~ '\v<function>'
		return "\<right>: "
	end
	if before =~ '\v\)$'
		return ": "
	end
	return ':'
endf
