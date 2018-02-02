
func! autotype#html#newline()
	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return "\<cr>"
	end
	if '><' == get(autotype#before(1), -1, '') . get(autotype#after(1), 0, '')
		return "\<cr>\<esc>O\<tab>"
	end
	return "\<cr>"
endf

func! autotype#html#bang()
	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return '!'
	end
	if getline('.') =~ '\v^\s*$' || autotype#after() =~ '\v^\s*$'
		return "<!--  -->\<esc>bhi"
	end
	return '!'
endf
