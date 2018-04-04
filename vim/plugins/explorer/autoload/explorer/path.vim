
" explorer#path#join([{pathN:string}, ...]) -> string
" Join paths. Trailing slashes are trimmed.
func! explorer#path#join(...)
	let path = substitute(join(a:000, '/'), '\v/+', '/', 'g')
	return substitute(path, '\v/+$', '', '')
endf
