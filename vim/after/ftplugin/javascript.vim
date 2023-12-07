
setl commentstring=//\ %s
setl noexpandtab
setl tabstop=2
setl shiftwidth=0

nnoremap <buffer> <f5> :!node %<cr>
inoremap <buffer> <f5> <esc>:!node %<cr>

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
