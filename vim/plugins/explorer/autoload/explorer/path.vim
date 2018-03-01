
func! explorer#path#join(a, b)
	return a:a . (a:a =~ '\v/$' ? '' : '/') . substitute(a:b, '\v(^/+|/+$)', '', 'g')
endf
