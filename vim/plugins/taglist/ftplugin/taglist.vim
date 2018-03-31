
" Set 'tags' using the value from the window we came from.
" Since 'tags' is set per filetype, this allows searches from the
" taglist buffer
let &tags = getwinvar(winnr('#'), '&tags', '')

nnoremap <silent> <buffer> q :close<cr>

nnoremap <silent> <buffer> <enter> :call <sid>jump('edit')<cr>
nnoremap <silent> <buffer> <c-j> :call <sid>jump('edit')<cr>
nnoremap <silent> <buffer> l :call <sid>jump('edit')<cr>
nnoremap <silent> <buffer> t :call <sid>jump('tabedit')<cr>
nnoremap <silent> <buffer> s :call <sid>jump('split')<cr>
nnoremap <silent> <buffer> v :call <sid>jump('vsplit')<cr>
nnoremap <silent> <buffer> p :call <sid>jump('pedit')<cr>

" Jump to the tag un the current line.
func! s:jump(cmd) abort
	let tag = get(b:taglist.table, line('.'), '')
	if empty(tag)
		return
	end
	close
	let path = substitute(tag.file, getcwd().'/', '', '')
	exec a:cmd fnameescape(path)
	exec tag.address
	norm! zz
endf

nnoremap <buffer> c :<c-u>call <sid>show_context()<cr>

" Display the line where the tag is located. If a count N is given,
" then N lines of context below and above the tag line are displayed.
func! s:show_context() abort
	let tag = get(b:taglist.table, line('.'), '')
	if empty(tag)
		return
	end
	if tag.address =~ '\v^\d+'
		let line = matchstr(tag.address, '\v\d+')
		let start = line - 1 - v:count
		let end = line - 1 + v:count
		echo join(readfile(tag.file)[start:end], "\n")
	elseif
		echo tag.address[2:-5]
	end
endf

func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
