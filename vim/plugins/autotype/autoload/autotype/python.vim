
func! autotype#python#newline()
	if g:autotype_disabled || autotype#inside('Comment')
		return "\<esc>o"
	end
	let line = getline('.')
	let keywords = ['def', 'class', 'if', 'elif', 'else', 'for', 'while', 'try', 'except', 'with']
	if line =~ '\v^\s*('.join(keywords, '|').')>' && line !~ '\v:$'
		call setline(line('.'), substitute(line, '\v\s*$', ':', ''))
	end
	return "\<esc>o"
endf
