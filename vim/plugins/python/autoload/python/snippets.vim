
let s:params = {
	\ '__format__': ['format_spec'],
	\ '__exit__': ['exec_type', 'exec_value', 'traceback'],
	\ '__lt__': ['other'], '__le__': ['other'], '__eq__': ['other'], '__ne__': ['other'], '__gt__': ['other'], '__ge__': ['other'],
	\ '__getitem__': ['key'], '__setitem__': ['key', 'value'], '__delitem__': ['key'], '__contains__': ['item'],
	\ '__getattribute__': ['key'], '__getattr__': ['key'], '__setattr__': ['name', 'value'], '__detlattr__': ['name'],
\ }

func python#snippets#func()
	if s:syntax_is('Comment', 'String')
		return ''
	end
	let before = strpart(getline('.'), 0, col('.') - 1)
	if before =~ '\v\w$'
		let is_method = match(before, '\v^\s+') >= 0  " approximation
		let fname = matchstr(before, '\v(\s|^)\zs\w+$')
		let is_magic = match(fname, '\v_$') >= 0
		let fname = is_magic ? '__' . fname[:-2] . '__' : fname
		let params = (is_method ? ['self'] : []) + get(s:params, fname, [])
		let newline = has_key(s:params, fname) ? "\<esc>o" : ''
		return printf("\<c-g>u\<c-w>def %s(%s):\<esc>hi%s", fname, join(params, ', '), newline)
	end
	return ''
endf

fun! s:syntax_is(...)
	let pattern = '\v^(' . join(a:000, '|') . ')$'
	return synIDattr(synIDtrans(synID(line('.'), col('.')-1, 0)), 'name') =~ pattern
endf
