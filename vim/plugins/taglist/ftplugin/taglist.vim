
" Set 'tags' using the value from the window we came from.
" Since 'tags' is set per filetype, this allows searches from the
" taglist buffer
let &tags = getwinvar(winnr('#'), '&tags', '')

" Jump to the tag un the current line.
fun! s:jump(cmd) abort
	let taglist_win = winnr()
	let tag = get(b:taglist.table, line('.'), '')
	if empty(tag)
		return
	end
	wincmd p
	exec taglist_win.'wincmd c'
	let path = substitute(tag.file, getcwd().'/', '', '')
	exec a:cmd fnameescape(path)
	exec tag.address
endf

" Display the line where the tag is located. If a count N is given,
" then N lines of context below and above the tag line are displayed.
fun! s:echo_context() abort
	let tag = get(b:taglist.table, line('.'), '')
	if !empty(tag) && tag.address =~ '\v^\d+'
		let linenr = str2nr(matchstr(tag.address, '\v^\d+'))
		let start = linenr - 1 - v:count
		let end = linenr - 1 + v:count
		echo join(readfile(tag.file)[start:end], "\n")
	end
endf

sil! nunmap vv

nnoremap <buffer> c :<c-u>call <sid>echo_context()<cr>

nnoremap <silent> <buffer> q :close<cr>
nnoremap <silent> <buffer> <enter> :call <sid>jump('edit')<cr>zz
nnoremap <silent> <buffer> <c-j> :call <sid>jump('edit')<cr>zz
nnoremap <silent> <buffer> o :call <sid>jump('edit')<cr>zz
nnoremap <silent> <buffer> e :call <sid>jump('edit')<cr>zz
nnoremap <silent> <buffer> t :call <sid>jump('tabedit')<cr>zz
nnoremap <silent> <buffer> s :call <sid>jump('split')<cr>zz
nnoremap <silent> <buffer> v :call <sid>jump('vsplit')<cr>zz
nnoremap <silent> <buffer> p :call <sid>jump('pedit')<cr>

nnoremap <silent> <buffer> <c-n> :call search('##', 'W')<cr>zz
nnoremap <silent> <buffer> <c-p> :call search('##', 'Wb')<cr>zz
