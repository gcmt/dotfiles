
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


" objects#emptyline({line:number|string}) -> bool
" Returns whether or not the given {line} is empty. {line} can be either a line
" number or a string.
func! objects#emptyline(line)
	let line = type(a:line) == v:t_number ? getline(a:line) : a:line
	return line =~ '\v^\s*$'
endf
