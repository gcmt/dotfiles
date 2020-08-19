
" Returns the characters to the left of the cursor
func! flow#before()
	return strpart(getline('.'), 0, col('.')-1)
endf

" Returns the characters to the right of the cursor
func! flow#after()
	return strpart(getline('.'), col('.')-1)
endf

" Returns the indent level for the given line
func! flow#indent(line)
	let line = type(a:line) == v:t_number ? getline(a:line) : a:line
	return strlen(matchstr(line, '\v^\s*'))
endf

" Returns the current line split in a half
func! flow#split_line_at_cursor(trim = 0)
	let [before, after] = [flow#before(), flow#after()]
	return a:trim ? [trim(before), trim(after)] : [before, after]
endf

" Check if the cursor is on the given syntax groups
func! flow#inside(...)
	let pattern = '\v^(' . join(a:000, '|') . ')$'
	return synIDattr(synIDtrans(synID(line('.'), col('.')-1, 0)), 'name') =~ pattern
endf

" Returns the syntax group at the given position
func! flow#synat(line, col)
	return synIDattr(synIDtrans(synID(a:line, a:col, 0)), 'name')
endf
