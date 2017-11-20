
setl commentstring=//\ %s

nnoremap <buffer> <f5> :!node %<cr>
inoremap <buffer> <f5> <esc>:!node %<cr>

nnoremap <silent> <buffer> <leader>o :Grep! ^(exports\\|module\.exports)\b<cr>

nnoremap <expr> <leader>; getline('.') !~ '\v;\s*$' ? 'm`A;<esc>``' : ''

command! Prettier call <sid>prettier()
nnoremap <silent> <buffer> <f4> :Prettier<cr>

func! s:prettier()
	let view_save = winsaveview()
	let options = '--use-tabs --single-quote --trailing-comma es5 --print-width 100'
	let file = shellescape(expand('%:p'))
	let out = system(printf('prettier %s %s', options, file))
	if v:shell_error
		echohl WarningMsg | echom "Prettier: An error occurred" | echohl END
		return
	end
	sil %delete _
	call setline(1, split(out, '\n'))
	call winrestview(view_save)
	sil! ALELint
endf
