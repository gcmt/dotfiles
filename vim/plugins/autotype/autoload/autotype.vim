
" Returns the characters to the left of the cursor
func! autotype#before()
	return strpart(getline('.'), 0, col('.')-1)
endf

" Returns the characters to the right of the cursor
func! autotype#after()
	return strpart(getline('.'), col('.')-1)
endf

" Check if the cursor is on the given syntax groups
func! autotype#inside(...)
	let pattern = '\v^(' . join(a:000, '|') . ')$'
	return synIDattr(synIDtrans(synID(line('.'), col('.')-1, 0)), 'name') =~ pattern
endf

" Returns the indent level for the given line
func! autotype#indent(line)
	let line = type(a:line) == v:t_number ? getline(a:line) : a:line
	return strlen(matchstr(line, '\v^\s*'))
endf
