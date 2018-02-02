
let s:pairs = {'{': '}', '[': ']', '(': ')', '"': '"', "'": "'", '`': '`'}

" Returns the characters to the left of the cursor as a list
" The last character is the current character
func s:before()
	return strpart(getline('.'), 0, col('.') - 1)
endf

" Returns the characters to the right of the cursor as a list
func s:after()
	return strpart(getline('.'), col('.') - 1)
endf

func pairs#insert(char)
	if &filetype == 'vim' && a:char == '"' && s:before() =~ '\v^\s*$'
		return a:char
	end
	if a:char == "'" && s:before() =~ '\v\a$'
		return a:char
	end
	if s:after() =~ "\\v^(\\w|'|\")"
		return a:char
	end
	return a:char . get(s:pairs, a:char, '') . "\<c-g>U\<left>"
endf

func pairs#space()
	let opening = matchstr(s:before(), '\v[[{(]\ze\s*$')
	let closing = matchstr(s:after(), '\v^\s*\zs[]})]')
	if !empty(opening) && closing == s:pairs[opening]
		return "\<space>\<space>\<left>"
	end
	return "\<c-]>\<space>"
endf

func pairs#delete(word)
	let opening = matchstr(s:before(), '\v[[{(]\ze\s+$')
	let closing = matchstr(s:after(), '\v^\s+\zs[]}\)]')
	if !empty(opening) && closing == s:pairs[opening]
		return "\<c-g>u\<esc>" . '"_ci' . opening
	end
	let opening = matchstr(s:before(), "\\v([[{(]|\"|')$")
	let closing = matchstr(s:after(), "\\v^([]})]|\"|')")
	if !empty(opening) && closing == s:pairs[opening]
		return "\<c-g>u\<right>\<bs>\<bs>"
	end
	return a:word ? "\<c-w>" : "\<bs>"
endf

func pairs#newline()
	let opening = matchstr(s:before(), '\v[[{(]$')
	let closing = matchstr(s:after(), '\v^[]})]')
	if !empty(opening) && closing == s:pairs[opening]
		return "\<c-g>u\<cr>\<esc>O"
	end
	return "\<c-]>\<cr>"
endf
