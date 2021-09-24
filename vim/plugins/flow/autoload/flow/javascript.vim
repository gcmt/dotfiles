
func! flow#javascript#setup()
	inoremap <silent> <buffer> ( <c-]><c-g>u<c-r>=flow#javascript#paren()<cr>
	inoremap <silent> <buffer> { <c-]><c-g>u<c-r>=flow#javascript#brace()<cr>
	inoremap <silent> <buffer> <c-t> <c-]><c-g>u<c-r>=flow#common#skipto('\v^\s*\}', 0)<cr>
	inoremap <silent> <buffer> <c-]> <c-]><c-g>u<c-r>=flow#common#skipto('\v^\s*\}', 1)<cr>
	inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=flow#javascript#space()<cr>
	inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=flow#javascript#esco()<cr>
	inoremap <expr> > flow#tag#autoclose()
endf

func! flow#javascript#esco()
	if g:flow_disabled || flow#inside('Comment')
		return "\<esc>o"
	end
	call flow#javascript#complete_line()
	return flow#common#esco()
endf

fun! flow#javascript#space()
	if g:flow_disabled || flow#inside('String', 'Comment') || !empty(flow#after())
		return flow#common#space()
	end
	let before = flow#before()
	let after = flow#after()
	if before =~ '\v\<(img|link|style|area|input)$' && after =~ '\v^\s*$'
		return "\<c-g>u  />\<left>\<left>\<left>"
	end
	if before =~ '\v<(for|while|if)$' || before =~ '\v^\s*}\selse\sif$'
		return " () {\<cr>}\<esc>k^f(a"
	end
	" if before =~ '\v<else $'
		" return " {\<cr>}\<esc>O"
	" end
	if before =~ '\v<class$'
		return "  {\<cr>}\<esc>O\<esc>kg_hi"
	end
	if before =~ '\v<(try|finally)$'
		return " {\<cr>}\<esc>O"
	end
	if before =~ '\v<catch$'
		return " (err) {\<cr>}\<esc>O"
	end
	return flow#common#space()
endf

func! flow#javascript#paren()
	if g:flow_disabled || flow#inside('String', 'Comment') || indent(line('.')) < indent(nextnonblank(line('.')+1))
		return flow#common#autoclose('(', ')')
	end
	let before = flow#before()
	let after = flow#after()
	if before =~ '\v<function(\*)?\s?\w*$' && after !~ '\v^\s*\{'
		let space = before =~ '\v<function(\*)?\s\w*$' ? '' : ' '
		return "" . space . "(\<esc>m`a) {\<cr>}\<esc>k``a"
	end
	if before =~ '\v^\s+(get |set |static )?\w+\s*$'
		let pos = searchpairpos('{', '', '}', 'nb')
		if getline(pos[0]) =~ '\v^\s*class>' || getline(pos[0]) =~ '\v\=\s*\{$'
			return "() {\<cr>}\<esc>kg_F(a"
		end
	end
	return flow#common#autoclose('(', ')')
endf

func! flow#javascript#brace()
	if g:flow_disabled || flow#inside('String', 'Comment')
		return flow#common#autoclose('{', '}')
	end
	let before = flow#before()
	if before =~ '\v<(else|) ?$'
		let space = before !~ ' $' ? ' ' : ''
		return space . "{}\<left>\<cr>\<esc>O"
	end
	return flow#common#autoclose('{', '}')
endf

func! flow#javascript#complete_line()
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
	" let next = getline(nextnonblank(line('.')+1))
	" if next !~ '\v^\s*\.'
		" call setline(line('.'), substitute(line, '\v\s*$', ';', ''))
	" end
endf
