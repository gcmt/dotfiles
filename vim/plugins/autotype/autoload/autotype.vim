
" returns the characters to the left of the cursor
" (the last character is the current character)
fun! autotype#before(...)
	let before = strpart(getline('.'), 0, col('.') - 1)
	return a:0 && a:1 ? split(before, '\zs') : before
endf

" returns the characters to the right of the cursor
fun! autotype#after(...)
	let after = strpart(getline('.'), col('.') - 1)
	return a:0 && a:1 ? split(after, '\zs') : after
endf

" check if the cursor is on the given syntax groups
fun! autotype#inside(...)
	let pattern = '\v^(' . join(a:000, '|') . ')$'
	return synIDattr(synIDtrans(synID(line('.'), col('.')-1, 0)), 'name') =~ pattern
endf

" returns the indent level for the given line
fun! autotype#indent(linenr)
	return strlen(matchstr(getline(a:linenr), '\v^\s*'))
endf
