
fun! flow#html#newline()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return "\<cr>"
	end
	if '><' == get(flow#before(1), -1, '') . get(flow#after(1), 0, '')
		return "\<cr>\<esc>O\<tab>"
	end
	return "\<cr>"
endf

fun! flow#html#bang()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return '!'
	end
	if getline('.') =~ '\v^\s*$' || flow#after() =~ '\v^\s*$'
		return "<!--  -->\<esc>bhi"
	end
	return '!'
endf
