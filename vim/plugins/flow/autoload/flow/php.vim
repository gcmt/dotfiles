
fun! flow#php#space()
	if g:flow_disabled || flow#inside('String', 'Comment') || flow#indent('.') < flow#indent(line('.')+1)
		return exists('g:loaded_pairs') ? pairs#space() : ' '
	end
	let before = flow#before()
	let after = flow#after()
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
	return exists('g:loaded_pairs') ? pairs#space() : ' '
endf

fun! flow#php#outward_parenthesis()
	if g:flow_disabled || flow#inside('String', 'Comment') || flow#indent('.') < flow#indent(line('.')+1)
		return exists('g:loaded_pairs') ? pairs#insert('(') : '('
	end
	let before = flow#before()
	let after = flow#after()
	if before =~ '\v<function \w*$' && after !~ '\v^\s*\{'
		return "(\<esc>m`a) {\<cr>}\<esc>k``a"
	end
	return exists('g:loaded_pairs') ? pairs#insert('(') : '('
endf

fun! flow#php#dot()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return '.'
	end
	if flow#before() =~ '\v\w$'
		return "->"
	end
	return '.'
endf

fun! flow#php#newline()
	if g:flow_disabled || flow#inside('Comment')
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

fun! flow#php#colon()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return ':'
	end
	let before = flow#before()
	let after = flow#after()
	if after =~ '\v^\)' && before =~ '\v<function>'
		return "\<right>: "
	end
	if before =~ '\v\)$'
		return ": "
	end
	return ':'
endf
