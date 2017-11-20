
setl nonumber
setl norelativenumber
setl cursorline

fun! _quickfix_title()
	let title = get(w:, 'quickfix_title', '')
	let title = substitute(title, &grepprg, get(split(&grepprg), 0, ''), '')
	let title = substitute(title, expand('#:p'), expand('#:t'), '')
	return substitute(title, $HOME, '~', 'g')
endf

setl stl=%t%{_quickfix_title()}

fun! s:set_quickfix_height()
	exec 'resize' float2nr(&lines * g:quickfix_height / 100)
	if line('$') < winheight(0)
		" make sure there are no visible empty lines
		exec 'resize' line('$')
	end
endf

call s:set_quickfix_height()

nnoremap <buffer> L <enter>zz
nnoremap <buffer> O <enter>zz
nnoremap <buffer> S <c-w><enter><c-w>x<c-w>pzz
nnoremap <buffer> T <c-w><enter><c-w>Tzz

let s:prefix = &stl =~ 'Quickfix' ? 'c' : 'l'
exec 'nnoremap <silent> <buffer> <c-j> <enter>:'.s:prefix.'close<cr>zz'
exec 'nnoremap <silent> <buffer> o <enter>:'.s:prefix.'close<cr>zz'
exec 'nnoremap <silent> <buffer> l <enter>:'.s:prefix.'close<cr>zz'
exec 'nnoremap <silent> <buffer> s <c-w><enter>:'.s:prefix.'close<cr>zz'
exec 'nnoremap <silent> <buffer> t <c-w><enter>:'.s:prefix.'close<cr><c-w>Tzz'
