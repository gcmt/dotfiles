
" explorer#path#join([{pathN:string}, ...]) -> string
" Join paths. Trailing slashes are trimmed.
func! explorer#path#join(...)
	let args = filter(copy(a:000), {-> !empty(v:val)})
	let path = substitute(join(args, '/'), '\v/+', '/', 'g')
	return substitute(path, '\v/+$', '', '')
endf

" explorer#path#dirname({path:string}) -> string
" Return the directory name of {path}.
func! explorer#path#dirname(path)
	let dirname = fnamemodify(a:path, ':h')
	return dirname != '.' ? dirname : ''
endf
