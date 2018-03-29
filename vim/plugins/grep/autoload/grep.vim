
func! s:run(cmd, args)

	" https://github.com/mileszs/ack.vim/issues/18
	let t_ti_save = &t_ti
	let t_te_save = &t_te
	set t_ti= t_te=
	let sp_save = &shellpipe
	set shellpipe=>

	let args = a:cmd =~ 'vim' ? a:args : join(map(split(a:args), 'shellescape(v:val)'))
	sil! exec a:cmd args

	let &shellpipe = sp_save
	let &t_ti = t_ti_save
	let &t_te = t_te_save

endf

func! grep#grep(grepcmd, args) abort

	call s:run(a:grepcmd, a:args)

	if len(getqflist()) == 0
		call s:err("Nothing found")
		cclose
	else
		copen
	end

endf

func! grep#grep_buffer(grepcmd, bang, args) abort

	let args = a:grepcmd =~ 'vim' ? '/'.a:args.'/' : a:args
	let scope = expand((&filetype == 'qf' ? '#' : '%').':p')
	call s:run(a:grepcmd, join([args, scope]))

	if !empty(a:bang)
		" remove matches in comments or strings
		let title = get(getqflist({'title': 1}), 'title', '')
		let fn = "s:synat(v:val['lnum'], v:val['col']) !~ '\\v(String|Comment)'"
		call setqflist(filter(getqflist(), fn), 'r')
		call setqflist([], 'a', {'title': title})
	end

	if len(getqflist()) == 0
		call s:err("Nothing found")
		cclose
	else
		let title = get(getqflist({'title': 1}), 'title', '')
		call setqflist([], 'a', {'title': substitute(title, '\V\^:', '%:', '')})
		copen
	end

endf

func! grep#prettify() abort
	if &bt != 'quickfix'
		throw "Grep: Not inside a quickfix buffer"
	end
	syn clear
	setl ma nolist
	let qf = getqflist()
	let width = len(max(map(copy(qf), 'v:val["lnum"]')))
	for linenr in range(len(qf))
		let line = printf("%".width."s %s", qf[linenr].lnum, qf[linenr].text)
		call setline(linenr+1, line)
	endfor
	call matchadd('LineNr', '\v^\s*\d+')
	setl noma nomod
endf

func! grep#try_prettify()
	if get(w:, 'quickfix_title', '') =~ '\V\^%'
		call grep#prettify()
	end
endf

func! s:synat(line, col)
	return synIDattr(synIDtrans(synID(a:line, a:col, 0)), 'name')
endf

func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf

aug _grep
	au!
	au BufWinEnter quickfix call grep#try_prettify()
	au User QfEditPostEdit call grep#try_prettify()
aug END
