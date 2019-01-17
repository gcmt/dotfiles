
func! autotype#javascript#setup()
	" inoremap <silent> <buffer> : <c-]><c-g>u<c-r>=autotype#javascript#colon()<cr>
	inoremap <silent> <buffer> ( <c-]><c-g>u<c-r>=autotype#javascript#outward_parenthesis()<cr>
	inoremap <silent> <buffer> <c-g><c-f> <c-]><c-g>u<c-r>=autotype#javascript#skip_to('\v\}')<cr>
	inoremap <silent> <buffer> { <c-]><c-g>u<c-r>=autotype#javascript#outward_brace()<cr>
	inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=autotype#javascript#space()<cr>
	inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=autotype#javascript#esc_o()<cr>
endf

fun! autotype#javascript#space()
	let Space = {-> exists('*pairs#space') ? pairs#space() : ' '}
	if g:autotype_disabled || autotype#inside('String', 'Comment') || !empty(autotype#after())
		return Space()
	end
	let before = autotype#before()
	if before =~ '\v<(for|while|if)$' || before =~ '\v^\s*}\selse\sif$'
		return " () {\<cr>}\<esc>k^f(a"
	end
	if before =~ '\v<else$'
		return " {\<cr>}\<esc>O"
	end
	if before =~ '\v<class$'
		return " {\<cr>}\<esc>O\<esc>kg_hi"
	end
	if before =~ '\v<(try|finally)$'
		return " {\<cr>}\<esc>O"
	end
	if before =~ '\v<catch$'
		return " (err) {\<cr>}\<esc>O"
	end
	return Space()
endf

func! autotype#javascript#outward_parenthesis()
	let Paren = {-> exists('*pairs#insert_paren') ? pairs#insert_paren('(') : '('}
	if g:autotype_disabled || autotype#inside('String', 'Comment') || indent(line('.')) < indent(nextnonblank(line('.')+1))
		return Paren()
	end
	let before = autotype#before()
	let after = autotype#after()
	if before =~ '\v<function(\*)?\s?\w*$' && after !~ '\v^\s*\{'
		let space = before =~ '\v<function(\*)?\s\w*$' ? '' : ' '
		return "" . space . "(\<esc>m`a) {\<cr>}\<esc>k``a"
	end
	if before =~ '\v^\s+(get |set |static )?\w+$'
		let pos = searchpairpos('{', '', '}', 'nb')
		if getline(pos[0]) =~ '\v^\s*class>' || getline(pos[0]) =~ '\v\=\s*\{$'
			return "() {\<cr>}\<esc>kg_F(a"
		end
	end
	return Paren()
endf

func! autotype#javascript#outward_brace()
	let Brace = {-> exists('*pairs#insert_paren') ? pairs#insert_paren('{') : '{'}
	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return Brace()
	end
	let before = autotype#before()
	let after = autotype#after()
	if before =~ '\v\{$' && after =~ '\v^}'
		return "\<cr>\<esc>O"
	end
	return Brace()
endf

func! autotype#javascript#colon()
	if g:autotype_disabled || autotype#inside('Comment', 'String')
		return ':'
	end
	if autotype#before() =~ '\v\S$'
		return ': '
	end
	return ':'
endf

func! autotype#javascript#esc_o()
	if g:autotype_disabled || autotype#inside('Comment')
		return "\<esc>o"
	end
	call autotype#javascript#complete_line()
	return "\<esc>o"
endf

func! autotype#javascript#skip_to(pattern, ...)
	call autotype#javascript#complete_line()
	let newline = a:0 > 0 && a:1 ? "\<cr>" : ''
	return search(a:pattern, 'Wce') ? "\<right>" . newline : ''
endf

func! autotype#javascript#complete_line()
	let line = getline('.')
	if line =~ '\v^\s*$' || line =~ '\v[;,+{\[(]\s*$'
		return
	end
	if line =~ '\v\s*}$'
		let pos = searchpairpos('{', '', '}', 'nb')
		if getline(pos[0]) =~ '\v^\s*class'
			" inside classes the comma in not necessary
			return
		end
		norm! g_h
		let pos = searchpairpos('{', '', '}', 'nb')
		if pos != [0, 0]
			if getline(pos[0]) =~ '\v^\s*(class|if|else|try|catch|finally|function|for|while)>' || getline(pos[0]) =~ '\v^\s*} (else|catch)>'
				return
			end
		end
		let pos = searchpairpos('{', '', '}', 'nb')
		if pos != [0, 0]
			let prev = getline(prevnonblank(pos[0]-1))
			if getline(pos[0]) !~ '\v\=\s*\{$' && (prev =~ '\v[\[(,]\s*$' || prev =~ '\v[:=(]\s*\{$')
				call setline(line('.'), substitute(line, '\v\s*$', ',', ''))
				return
			end
		end
	end
	let prev = getline(prevnonblank(line('.')-1))
	if line !~ '\v[,;+{]$' && (prev =~ '\v[\[(,]\s*$' || prev =~ '\v[:=(]\s*\{$')
		call setline(line('.'), substitute(line, '\v\s*$', ',', ''))
		return
	end
	let next = getline(nextnonblank(line('.')+1))
	if next !~ '\v^\s*\.'
		call setline(line('.'), substitute(line, '\v\s*$', ';', ''))
	end
endf
