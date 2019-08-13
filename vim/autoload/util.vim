
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
	setl ft=regedit bt=nofile bh=wipe nobl
	call setwinvar(winnr(), "&stl", " [Register " . reg . "]")

	let reg_content = getreg(reg, 1, 1)
	call append(0, reg_content)
	sil norm! G_ddgg
	exec "resize" min([max([len(reg_content), 5]), float2nr(&lines * 50 / 100)])

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
