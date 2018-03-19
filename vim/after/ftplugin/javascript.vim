
setl commentstring=//\ %s

nnoremap <buffer> <f5> :!node %<cr>
inoremap <buffer> <f5> <esc>:!node %<cr>

nnoremap <silent> <buffer> <leader>o :Greb ^(exports\\|module\.exports)\b<cr>

nnoremap <silent> <leader>; :call autotype#javascript#complete_line()<cr>
inoremap <silent> <c-g><c-c> <c-]><esc>:call autotype#javascript#complete_line()<cr>

nnoremap <silent> ) :<c-u>call <sid>next('\v<(function\|class\|try\|catch\|if\|else\|for\|while\|let\|const\|var)>', 0)<cr>
nnoremap <silent> ( :<c-u>call <sid>next('\v<function>', 1)<cr>
nnoremap <silent> ]] :<c-u>call <sid>next('\v<function>', 0)<cr>
nnoremap <silent> [[ :<c-u>call <sid>next('\v<function>', 1)<cr>
nnoremap <silent> ]c :<c-u>call <sid>next('\v^\s*\zsclass>', 0)<cr>
nnoremap <silent> [c :<c-u>call <sid>next('\v^\s*\zsclass>', 1)<cr>

func! s:next(pattern, backward)
	let flags = 'Ws' . (a:backward ? 'b' :'')
	let n = v:count1
	while n > 0
		if search(a:pattern, flags) && s:inside('Comment', 'String')
			continue
		end
		let n -= 1
	endw
endf

" check if the cursor is on the given syntax groups
func! s:inside(...)
	let pattern = '\v^(' . join(a:000, '|') . ')$'
	return synIDattr(synIDtrans(synID(line('.'), col('.')-1, 0)), 'name') =~ pattern
endf

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
