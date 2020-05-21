

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
"
func! util#bdelete(cmd, bang)

	let target = bufnr("%")

	if &modified && empty(a:bang)
		return util#errm('E89 No write since last change for buffer %d (add ! to override)', target)
	end

	let Fn = {i, nr -> buflisted(nr) && empty(getbufvar(nr, '&bt'))}
	let buffers = filter(range(1, bufnr('$')), Fn)

	" select the next buffer as a replacement buffer
	let repl = buffers[(index(buffers, target)+1) % len(buffers)]

	if repl == target
		if empty(bufname(target))
			" there are no more named buffers to switch to
			return
		end
		call win_execute(bufwinid(target), 'enew')
	else
		while bufwinid(target) != -1
			call win_execute(bufwinid(target), 'buffer ' . repl)
		endw
	end

	let cmd = a:cmd
	if getbufvar(target, '&buftype') == 'terminal'
		let cmd = 'bwipe!'
	end

	try
		exec cmd target
	catch /E.*/
		return s:err(matchstr(v:exception, '\vE\d+:.*'))
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
"   - fmt (string): format string eg. '%foo%( - %{bar}baz%)'
"   - repl (dict): replacement values eg {'foo': 'Foo', 'bar': 'Bar'}
"   - positions (bool): whether or not to also return replacements positions
"
func! util#fmt(fmt, repl, positions = 0) abort

	let s = a:fmt
	" the string after % or inside %{}
	let placeholder = ""
	" magic == 1: % has been found, expecting placeholder, parenthesis or brace
	let magic = 0
	" braces == 1: braces expected to delimit a placeholder
	let braces = 0
	" how many successful replacements in a group
	let repls = [0]
	" top element is the current group
	let groups = [""]
	" the top element is the current position in the result string
	let position = [0]
	" replacements positions
	let positions = []

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
			call add(position, position[-1])
			continue
		end

		" Group ended
		if s[i] == ')' && empty(placeholder) && magic
			let magic = 0
			if len(groups) < 2
				throw s:ParseError("Unbalanced parenthesis: %s", a:fmt)
			end
			let group = remove(groups, -1)
			let pos = remove(position, -1)
			if remove(repls, -1)
				" Append the group to the container but only if any
				" replacement happened inside the group
				let groups[-1] .= group
				let position[-1] = pos
			end
			continue
		end

		" Check for placeholder end
		if (s[i] !~ '\v[a-z_]' && !empty(placeholder) || s[i] =~ '\v[a-z_]' && i == len(s)-1) && magic
			if i == len(s)-1 && s[i] =~ '\v[a-z_]'
				let placeholder .= s[i]
			end
			let repl = get(a:repl, placeholder, '')
			let groups[-1] .= repl
			let repls[-1] += len(repl) ? 1 : 0
			if len(repl)
				call add(positions, [placeholder, position[-1], position[-1]+len(repl)-1])
				let position[-1] += len(repl)
			end
			let magic = 0
			let placeholder = ''
			if i == len(s)-1 && s[i] =~ '\v[a-z_]'
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

		if s[i] == '%' && empty(placeholder)
			" When %% is used, a single % is inserted
			let magic = !magic
			if magic
				continue
			end
		end

		let groups[-1] .= s[i]
		let position[-1] += 1
	endfo

	if len(groups) > 1
		throw s:ParseError("Unbalanced parenthesis: %s", a:fmt)
	end

	if a:positions
		return [groups[0], positions]
	else
		return groups[0]
	end

endf


func! util#test_fmt() abort

	let testdata = [
		\ #{
			\ fmt: "%%{foo} %%bar %baz",
			\ repl: #{foo: 'Foo', bar: 'Bar', baz: "Baz"},
			\ expected_str: '%{foo} %bar Baz',
			\ expected_pos: [['baz', 12, 14]],
		\ },
		\ #{
			\ fmt: "%{foo}bar%( | %{baz}%)",
			\ repl: #{foo: 'Foo', baz: "Baz"},
			\ expected_str: 'Foobar | Baz',
			\ expected_pos: [['foo', 0, 2], ['baz', 9, 11]],
		\ },
		\ #{
			\ fmt: "%foo%( - %bar%( | %baz%) %qux%) (%qux)",
			\ repl: #{foo: 'Foo', bar: 'Bar', baz: "", qux: "Qux"},
			\ expected_str: 'Foo - Bar Qux (Qux)',
			\ expected_pos: [['foo', 0, 2], ['bar', 6, 8], ['qux', 10, 12], ['qux', 15, 17]],
		\ },
		\ #{
			\ fmt: "%foo%( - %bar%( | %baz%) %qux%)",
			\ repl: #{foo: 'Foo', bar: 'Bar', baz: "Baz", qux: "Qux"},
			\ expected_str: 'Foo - Bar | Baz Qux',
			\ expected_pos: [['foo', 0, 2], ['bar', 6, 8], ['baz', 12, 14], ['qux', 16, 18]],
		\ },
		\ #{
			\ fmt: "%foo%( - %bar%( | %baz%) %qux%)",
			\ repl: #{foo: 'Foo', bar: '', baz: 'Baz', qux: "Qux"},
			\ expected_str: 'Foo -  | Baz Qux',
			\ expected_pos: [['foo', 0, 2], ['baz', 9, 11], ['qux', 13, 15]],
		\ },
		\ #{
			\ fmt: "%foo%( - %bar%( | %baz%) %qux%)",
			\ repl: #{foo: 'Foo', bar: '', baz: '', qux: "Qux"},
			\ expected_str: 'Foo -  Qux',
			\ expected_pos: [['foo', 0, 2], ['qux', 7, 9]],
		\ },
		\ #{
			\ fmt: "%foo%( - %bar%( | %baz%)%) %qux",
			\ repl: #{foo: 'Foo', bar: '', baz: '', qux: "Qux"},
			\ expected_str: 'Foo Qux',
			\ expected_pos: [['foo', 0, 2], ['qux', 4, 6]],
		\ },
		\ #{
			\ fmt: "%(%foo%( - %bar%( | %baz%)%)%)",
			\ repl: #{foo: '', bar: '', baz: ''},
			\ expected_str: '',
			\ expected_pos: [],
		\ },
	\ ]

	echon "TEST util#test_fm"

	let i = 1
	for t in testdata
		let v:errors = []

		let [str, pos] = util#fmt(t.fmt, t.repl, 1)
		call assert_equal(t.expected_str, str)
		call assert_equal(t.expected_pos, pos)

		if !empty(v:errors)
			call util#errm("Test #%d: FAIL", i)
			for err in v:errors
				call util#errm(err)
			endfo
			echo
		else
			echo printf("Test #%d: OK", i)
		end

		let i += 1
	endfo

	echo

endf

" nnoremap <buffer> <enter> :so %<cr>:call util#test_fmt()<cr>
