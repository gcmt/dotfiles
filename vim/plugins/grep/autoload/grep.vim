
func! s:run(cmd, args)

	" https://github.com/mileszs/ack.vim/issues/18
	let t_ti_save = &t_ti
	let t_te_save = &t_te
	set t_ti= t_te=
	let sp_save = &shellpipe
	set shellpipe=>

	sil! exec a:cmd a:args

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

	let args  = a:grepcmd =~ 'vim' ? '/'.a:args.'/' : a:args
	let args .= ' ' . expand((&filetype == 'qf' ? '#' : '%').':p')
	call s:run(a:grepcmd, args)

	if !empty(a:bang)
		" remove matches in comments or strings
		let qf = getqflist({'all': 1})
		let Fn = {i, entry -> s:synat(entry['lnum'], entry['col']) !~ '\v(String|Comment)'}
		call filter(qf.items, Fn)
		call setqflist([], 'r', qf)
	end

	if len(getqflist()) == 0
		call s:err("Nothing found")
		cclose
	else
		call setqflist([], 'a', {'context': {'prettify': 1}})
		copen
	end

endf

func! s:prettify(...) abort
	let context = getqflist({'context': 1}).context
	if type(context) != v:t_dict || !get(context, 'prettify', 0)
		return
	end
	syn clear
	setl nolist modifiable
	let qf = getqflist()
	let width = len(max(map(copy(qf), 'v:val["lnum"]')))
	let b:grep_numbers = a:0 > 0 ? a:1 : get(b:, 'grep_numbers', 1)
	for i in range(len(qf))
		let num = printf("%".width."s ", qf[i].lnum)
		let line = (b:grep_numbers ? num : "") . qf[i].text
		call setline(i+1, line)
	endfor
	setl nomodifiable nomodified
	call matchadd('LineNr', '\v^\s*\d+')
	nnoremap <silent> <buffer> a :call <sid>prettify(1-b:grep_numbers)<cr>
endf

func! s:synat(line, col)
	return synIDattr(synIDtrans(synID(a:line, a:col, 0)), 'name')
endf

func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf

aug _grep
	au!
	au BufWinEnter quickfix call s:prettify()
	au User QuickFixEditPost call s:prettify()
aug END
