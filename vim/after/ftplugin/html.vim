
setl nonumber
setl norelativenumber
setl matchpairs+=<:>

" switch to tab
imap <buffer> <c-t> <plug>(taggify-inline)

inoremap <silent> <buffer> <c-a> <c-r>=_jump_after('\v\</\a+\>')<cr>

nnoremap <buffer> <silent> <c-n> :call <sid>next_tag(0)<cr>
nnoremap <buffer> <silent> <c-p> :call <sid>next_tag(1)<cr>

func! s:next_tag(backward)
	let flags = 'W' . (a:backward ? 'b' : '')
	if search('\v\<\zs\a+', flags)
		" set cursorline
	end
endf

func! s:jump_after_closing_tag()
	return search("\\v\\</(\"[^\"]*\"|'[^']*'|[^\"'>])*\\>", 'W') ? "\<esc>f>a" : ''
endf
