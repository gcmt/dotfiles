
func! flow#common#setup()
	inoremap <expr> { flow#common#autoclose('{', '}')
	inoremap <expr> [ flow#common#autoclose('[', ']')
	inoremap <expr> ( flow#common#autoclose('(', ')')
	inoremap <expr> " flow#common#autoclose_string('"')
	inoremap <expr> ' flow#common#autoclose_string("'")
	inoremap <expr> ` flow#common#autoclose_string("`")
	inoremap <expr> <bs> flow#common#delete()
	inoremap <expr> <c-h> flow#common#delete()
	inoremap <expr> <space> flow#common#space()
	inoremap <expr> <enter> flow#common#newline()
	inoremap <expr> <c-d> flow#common#esco()
endf

func! flow#common#autoclose(start, end)
	if flow#after() =~ '\v^(\w)'
		return a:start
	end
	return a:start . a:end . "\<c-g>U\<left>"
endf

func! flow#common#autoclose_string(quote)
	let [before, after] = flow#split_line_at_cursor()
	if &ft == 'vim' && a:quote == '"' && before =~ '\v^\s*$'
		return a:quote
	end
	if a:quote == "'" && flow#synat(line('.'), col('.')) == 'String' && before =~ '\v\a$'
		return a:quote
	end
	if after =~ '\v^\a' || before =~ '\v\a$'
		return a:quote
	end
	if count(getline('.'), a:quote) % 2 != 0
		return a:quote
	end
	return a:quote . a:quote . "\<c-g>U\<left>"
endf

func! flow#common#space()
	let [before, after] = flow#split_line_at_cursor(1)
	let pair = before[len(before)-1] . after[0]
	if pair == '()' || pair == '[]' || pair == '{}' || pair == '<>'
		return "\<space>\<space>\<left>"
	end
	return "\<c-]>\<space>"
endf

func! flow#common#delete()
	let [before, after] = flow#split_line_at_cursor(1)
	let pair = before[len(before)-1] . after[0]
	if  pair == "''" || pair == '""'
		return "\<c-g>U\<right>\<bs>\<bs>"
	end
	if pair == '()' || pair == '[]' || pair == '{}' || pair == '<>'
		let before_spaces = matchstr(before, " *$")
		let after_spaces = matchstr(after, "^ *")
		if len(before_spaces) == len(after_spaces)
			return "\<c-g>U\<right>\<bs>\<bs>"
		elseif len(before_spaces) < len(after_spaces)
			return "\<c-g>U\<right>\<bs>"
		elseif len(before_spaces) > len(after_spaces)
			return "\<c-g>U\<bs>"
		end
	end
	return "\<c-g>U\<bs>"
endf

func! flow#common#newline()
	let [before, after] = flow#split_line_at_cursor()
	let pair = before[len(before)-1] . after[0]
	if pair == '()' || pair == '[]' || pair == '{}' || pair == '><'
		return "\<c-g>u\<cr>\<esc>O"
	end
	return "\<c-]>\<c-g>u\<cr>"
endf

func! flow#common#esco()
	if g:flow_disabled || flow#inside('Comment')
		return "\<esc>o"
	end
	if line('.') != line('$') && getline(line('.')+1) =~ '\v^\s*$'
		return "\<down>\<c-f>"
	end
	return "\<esc>o"
endf

func! flow#common#skipto(pattern, newline = 0)
	let newline = a:newline ? "\<esc>o" : ''
	return search(a:pattern, 'Wce') ? "\<right>" . newline : ''
endf
