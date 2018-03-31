
" Set 'tags' using the value from the window we came from.
" Since 'tags' is set per filetype, this allows searches from the
" taglist buffer
let &tags = join(b:taglist.tagfiles, ',')

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

nnoremap <silent> <buffer> a :<c-u>call <sid>toggle_tagfiles()<cr>

func! s:toggle_tagfiles()
	let g:taglist_visible_tagfiles = 1 - g:taglist_visible_tagfiles
	let pos_save = getcurpos()[1:2]
	let line_save = matchstr(getline('.'), '\v\w.*')
	call taglist#render()
	if !search('\V' . escape(line_save, '\') . '\$')
		call cursor(pos_save)
	end
	norm! 0
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
