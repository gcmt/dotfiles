
" Returns the syntax group at the given position.
" If no position is given, it defaults to the cursor position.
func! objects#syntax(...)
	let pos = a:0 == 2 ? [a:1, a:2] : [line('.'), col('.')]
	return synIDattr(synIDtrans(synID(pos[0], pos[1], 0)), 'name')
endf
