
" objects#synat(['.' | [line:number, col:number]]) -> string
" Returns the syntax group at the given position.
" When the only argument is the '.' expression, the syntax at the current cursor
" position is returned.
func! objects#synat(...)
	if a:0 == 1 && a:1 == '.'
		let [line, col] = [line('.'), col('.')]
	elseif a:0 == 2 && type(a:1) == v:t_number && type(a:2) == v:t_number
		let [line, col] = [a:1, a:2]
	else
		throw "Wrong arguments for function: objects#synat"
	end
	return synIDattr(synIDtrans(synID(line, col, 0)), 'name')
endf
