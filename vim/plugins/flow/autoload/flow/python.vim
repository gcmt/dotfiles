
fun! flow#python#newline()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return "\<esc>o"
	end
	let line = getline('.')
	let keywords = ['def', 'class', 'if', 'else', 'for', 'try', 'except']
	if line =~ '\v^\s*('.join(keywords, '|').')>' && line !~ '\v:\s*$'
		call setline(line('.'), substitute(line, '\v\s*$', ':', ''))
	end
	return "\<esc>o"
endf
