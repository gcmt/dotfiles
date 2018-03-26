
" Returns the syntax group under the cursor
func! objects#cursyn()
	return synIDattr(synIDtrans(synID(line('.'), col('.'), 0)), 'name')
endf

" Returns the syntax group at the given position.
func! objects#synat(line, col)
	return synIDattr(synIDtrans(synID(a:line, a:col, 0)), 'name')
endf
