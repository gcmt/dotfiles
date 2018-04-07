
setl nonumber
setl norelativenumber
setl cursorline

fun! _quickfix_title()
	let title = get(w:, 'quickfix_title', '')
	let title = substitute(title, &grepprg, get(split(&grepprg), 0, '') . ' ', '')
	return substitute(title, $HOME, '~', 'g')
endf

setl stl=%t\ %{_quickfix_title()}

func! s:set_height(percentage)
	exec 'resize' float2nr(&lines * a:percentage / 100)
	if line('$') <= winheight(0)
		exec 'resize' line('$')
	else
		echo "Scroll for more results"
	end
endf

call s:set_height(get(g:, 'quickfix_height', 25))

nnoremap <buffer> q <c-w>c

" don't close the quickfix window
nnoremap <silent> <buffer> L <enter>zz
nnoremap <silent> <buffer> S <c-w><enter><c-w>x<c-w>pzz
nnoremap <silent> <buffer> T <c-w><enter><c-w>Tzz

nnoremap <silent> <buffer> l <enter>:exec winnr('#').'wincmd c'<cr>zz
nnoremap <silent> <buffer> s <c-w><enter>:exec winnr('#').'wincmd c'<cr>zz
nnoremap <silent> <buffer> t <c-w><enter>:exec winnr('#').'wincmd c'<cr><c-w>Tzz
nmap <buffer> <c-j> <enter>

nnoremap <silent> <buffer> <c-p> :colder<cr>
nnoremap <silent> <buffer> <c-n> :cnewer<cr>

norm! zz
