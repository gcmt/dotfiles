

" Search withouth moving the cursor
func! util#search(visual)
	if a:visual && line("'<") != line("'>")
		return
	end
	if a:visual
		let selection = getline('.')[col("'<")-1:col("'>")-1]
		let pattern = '\V' . escape(selection, '/\')
	else
		let pattern = '\<' . expand('<cword>') . '\>'
	end
	if @/ == pattern
		let @/ = ''
		set nohlsearch
	else
		let @/ = pattern
		set hlsearch
	end
endf


" Edit register in a buffer
func! util#regedit(reg)
	let reg = empty(a:reg) ? '"' : a:reg

	exec "sil keepj keepa botright 1new __regedit__"
	setl ft=regedit bt=nofile bh=wipe nobl noudf nobk noswf nospell
	call setwinvar(winnr(), "&stl", " [Register " . reg . "]")

	let reg_content = getreg(reg, 1, 1)
	call append(1, reg_content)
	sil norm! "_dd

	let min_size = 5
	let max_size = float2nr(&lines * 50 / 100)
	exec "resize" min([max([len(reg_content), min_size]), max_size])

	nno <silent> <buffer> q <c-w>c
	nno <silent> <buffer> <cr> :let b:regedit_save = 1<bar>close<cr>
	nno <silent> <buffer> <c-j> :let b:regedit_save = 1<bar>close<cr>

	let b:regedit_reg = reg
	au BufWipeout <buffer> if get(b:, "regedit_save") |
		\ call setreg(b:regedit_reg, join(getline(0, "$"), "\n")) | end

endf


" Delete the buffer without closing the window
func! util#bdelete(cmd, bang)

	let winnr = winnr()
	let bufnr = bufnr('%')

	if &modified && empty(a:bang)
		return util#errm('E89 No write since last change for buffer %d (add ! to override)', bufnr)
	end

	let prev_winnr = -1
	while 1
		let cur_winnr = bufwinnr(bufnr)
		if cur_winnr == -1 || cur_winnr == prev_winnr
			break
		end
		exec cur_winnr 'wincmd w'
		let prev_winnr = cur_winnr
		let repl = -1
		if buflisted(bufnr('#'))
			let repl = bufnr('#')
		else
			for b in range(1, bufnr('$'))
				if buflisted(b) && b != bufnr
					let repl = b
					break
				end
			endfo
		end
		if repl > -1
			sil exec 'buffer' repl
		else
			enew
		end
	endw

	exec winnr 'wincmd w'

	try
		exec a:cmd.a:bang bufnr
		echom a:cmd.a:bang bufname(bufnr)
	catch /E.*/
		return util#errm(matchstr(v:exception, '\vE\d+:.*'))
	endtry

endf


" Clear undo history (:h clear-undo)
func! util#clear_undo()
	let modified_save = &modified
	let undolevels_save = &undolevels
	let line_save = getline('.')
	set undolevels=-1
	exec "norm! a \<bs>\<esc>"
	call setline('.', line_save)
	let &undolevels = undolevels_save
	let &modified = modified_save
endf


func! util#err(fmt, ...)
	echohl WarningMsg | echo call('printf', [a:fmt] + a:000)  | echohl None
endf


func! util#errm(fmt, ...)
	echohl WarningMsg | echom call('printf', [a:fmt] + a:000)  | echohl None
endf


func! s:ParseError(msg, ...)
	return "ParseError: " . call('printf', [a:msg] + a:000)
endf


" String formatting with conditional groups.
" Groups are expanded only if at least one successful non-empty replacement
" happened inside them.
"
" Args:
"   - fmt (string): foramt string eg. '%foo%( - %{bar}baz%)'
"   - repl (dict): replacement values
"
func! util#fmt(fmt, repl) abort

	let s = a:fmt
	" the string after % or inside %{}
	let placeholder = ""
	" when magic == 1: % has been found, expecting identifier, parenthesis
	" or brace next
	let magic = 0
	" braces == 1: braces are used to delimit a palceholder
	let braces = 0
	" how many successful replacements in a group
	let repls = [0]
	" group stack
	let groups = [""]

	for i in range(0, len(s)-1)

		if braces && s[i] !~ '\v[a-z_}]'
			throw s:ParseError("Invalid placeholder character: '%s'", s[i])
		end

		" User is using braces to delimit a placeholder
		if s[i] == '{' && magic
			let braces = 1
			continue
		end

		" A group as started
		if s[i] == '(' && empty(placeholder) && magic
			let magic = 0
			call add(repls, 0)
			call add(groups, "")
			continue
		end

		" Group ended
		if s[i] == ')' && empty(placeholder) && magic
			let magic = 0
			if len(groups) < 2
				throw s:ParseError("Unbalanced parenthesis: %s", a:fmt)
			end
			let group = remove(groups, -1)
			if remove(repls, -1)
				" Append the group to the container but only if any
				" replacement happened inside the group
				let groups[-1] .= group
			end
			continue
		end

		" Check for placeholder end
		if (s[i] !~ '\v[a-z_]' || s[i] =~ '\v[a-z_]' && i == len(s)-1) && magic
			if i == len(s)-1 && s[i] =~ '\v[a-z_]'
				let placeholder .= s[i]
			end
			if empty(placeholder)
				throw s:ParseError("Invalid placeholder: %s", a:fmt)
			end
			let repl = get(a:repl, placeholder, '')
			let groups[-1] .= repl
			let repls[-1] += len(repl) ? 1 : 0
			let magic = 0
			let placeholder = ''
			if i == len(s)-1 && s[i] =~ '\v[a-z]'
				continue
			end
			if s[i] == '}'
				let braces = 0
				continue
			end
		end

		if s[i] =~ '\v[a-z]' && magic
			let placeholder .= s[i]
			continue
		end

		if s[i] == '%'
			if !magic
				let magic = 1
			else
				" When using %% an single % is inserted
				let magic = 0
				let groups[-1] .= '%'
			end
			continue
		end

		let groups[-1] .= s[i]
	endfo

	if len(groups) > 1
		throw s:ParseError("Unbalanced parenthesis: %s", a:fmt)
	end

	return groups[0]

endf


func! util#test_fmt() abort

	let testdata = [
		\ #{
			\ fmt: "%foo%( - %bar%( | %baz%) %qux%) (%qux)",
			\ repl: #{foo: 'Foo', bar: 'Bar', baz: "", qux: "Qux"},
			\ expected: 'Foo - Bar Qux (Qux)',
		\ },
		\ #{
			\ fmt: "%foo%( - %bar%( | %baz%) %qux%)",
			\ repl: #{foo: 'Foo', bar: 'Bar', baz: "Baz", qux: "Qux"},
			\ expected: 'Foo - Bar | Baz Qux',
		\ },
		\ #{
			\ fmt: "%foo%( - %bar%( | %baz%) %qux%)",
			\ repl: #{foo: 'Foo', bar: '', baz: 'Baz', qux: "Qux"},
			\ expected: 'Foo -  | Baz Qux',
		\ },
		\ #{
			\ fmt: "%foo%( - %bar%( | %baz%) %qux%)",
			\ repl: #{foo: 'Foo', bar: '', baz: '', qux: "Qux"},
			\ expected: 'Foo -  Qux',
		\ },
		\ #{
			\ fmt: "%foo%( - %bar%( | %baz%)%) %qux",
			\ repl: #{foo: 'Foo', bar: '', baz: '', qux: "Qux"},
			\ expected: 'Foo Qux',
		\ },
	\ ]

	echon "TEST util#test_fm: "

	let i = 0
	for t in testdata
		let v:errors = []
		call assert_equal(t.expected, util#fmt(t.fmt, t.repl))
		if !empty(v:errors)
			call util#errm("Test #%d failed: %s", i, join(v:errors, '; '))
			break
		end
		echon "."
		let i += 1
	endfo

	echon " OK"
	echo

endf

nnoremap <buffer> <enter> :so %<cr>:call util#test_fmt()<cr>
