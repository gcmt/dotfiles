
setl nonumber
setl norelativenumber
setl matchpairs+=<:>

imap <buffer> <c-c> <c-y>,
vmap <buffer> <c-c> <c-y>,

fun! s:jump_after_closing_tag()
	return search("\\v\\</(\"[^\"]*\"|'[^']*'|[^\"'>])*\\>", 'W') ? "\<esc>f>a" : ''
endf
