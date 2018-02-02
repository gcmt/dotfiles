
setl nonumber
setl norelativenumber
setl cursorline

fun! _quickfix_title()
	let title = get(w:, 'quickfix_title', '')
	let title = substitute(title, &grepprg, get(split(&grepprg), 0, '') . ' ', '')
	return substitute(title, $HOME, '~', 'g')
endf

setl stl=%t\ %{_quickfix_title()}

nnoremap <buffer> q <c-w>c

nnoremap <buffer> L <enter>zz:set cul<cr>
nnoremap <buffer> O <enter>zz:set cul<cr>
nnoremap <buffer> S <c-w><enter><c-w>x<c-w>pzz:set cul<cr>
nnoremap <buffer> T <c-w><enter><c-w>Tzz:set cul<cr>

nnoremap <silent> <buffer> <c-j> <enter>:exec winnr('#').'wincmd c'<cr>zz:set cul<cr>
nnoremap <silent> <buffer> <enter> <enter>:exec winnr('#').'wincmd c'<cr>zz:set cul<cr>
nnoremap <silent> <buffer> l <enter>:exec winnr('#').'wincmd c'<cr>zz:set cul<cr>
nnoremap <silent> <buffer> o <enter>:exec winnr('#').'wincmd c'<cr>zz:set cul<cr>
nnoremap <silent> <buffer> s <c-w><enter>:exec winnr('#').'wincmd c'<cr>zz:set cul<cr>
nnoremap <silent> <buffer> t <c-w><enter>:exec winnr('#').'wincmd c'<cr><c-w>Tzz:set cul<cr>

nnoremap <silent> <buffer> <c-w>_ :call <sid>set_height(100)<cr>

func! s:set_height(percentage)
	exec 'resize' float2nr(&lines * a:percentage / 100)
	if line('$') <= winheight(0)
		exec 'resize' line('$')
	else
		echo "Scroll for more results"
	end
endf

call s:set_height(get(g:, 'quickfix_height', 25))
