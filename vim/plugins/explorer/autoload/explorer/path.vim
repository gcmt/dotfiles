
" explorer#path#join([{pathN:string}, ...]) -> string
" Join paths.
func! explorer#path#join(...)
	let path = join(a:000, '/')
	return substitute(path, '\v/+', '/', 'g')
endf
