
let s:closing = {'{': '}', '[': ']', '(': ')', '"': '"', "'": "'", '`': '`'}

" Returns the characters to the left of the cursor as a list
" The last character is the current character
func! s:before()
	return strpart(getline('.'), 0, col('.') - 1)
endf

" Returns the characters to the right of the cursor as a list
func! s:after()
	return strpart(getline('.'), col('.') - 1)
endf

func! pairs#insert_paren(par)
	if s:after() =~ "\\v^(\\w|\"|')"
		return a:par
	end
	return a:par . get(s:closing, a:par, '') . "\<c-g>U\<left>"
endf

func! pairs#insert_quote(quote)
	let after = s:after()
	let before = s:before()
	if &ft == 'vim' && a:quote == '"' && before =~ '\v^\s*$'
		return a:quote
	end
	if a:quote == "'" && before =~ '\v\a$'
		return a:quote
	end
	if count(getline('.'), a:quote) % 2 != 0
		return a:quote
	end
	return a:quote . a:quote . "\<c-g>U\<left>"
endf

func! pairs#space()
	let opening = matchstr(s:before(), '\v[[{(]\ze\s*$')
	let closing = matchstr(s:after(), '\v^\s*\zs[]})]')
	if !empty(opening) && closing == s:closing[opening]
		return "\<space>\<space>\<left>"
	end
	return "\<c-]>\<space>"
endf

func! pairs#delete(keys)
	let after = s:after()
	let before = s:before()
	let opening = matchstr(before, '\v[[{(]\ze\s+$')
	let closing = matchstr(after, '\v^\s+\zs[]}\)]')
	if !empty(opening) && closing == s:closing[opening]
		return "\<c-g>u\<esc>" . '"_ci' . opening
	end
	let opening = matchstr(before, "\\v([[{(]|\"|'|`)$")
	let closing = matchstr(after, "\\v^([]})]|\"|'|`)")
	if !empty(opening) && closing == s:closing[opening]
		if opening =~ "\\v('|\")" && count(after, opening) % 2 == 0
			return a:keys
		end
		return "\<c-g>u\<right>\<bs>\<bs>"
	end
	return a:keys
endf

func! pairs#newline()
	let opening = matchstr(s:before(), '\v[[{(]$')
	let closing = matchstr(s:after(), '\v^[]})]')
	if !empty(opening) && closing == s:closing[opening]
		return "\<c-g>u\<cr>\<esc>O"
	end
	return "\<c-]>\<cr>"
endf
