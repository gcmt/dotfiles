" =============================================================================
" File: commenter.vim
" Description: Comment operator
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

if exists("g:loaded_commenter") || &cp
    finish
end
let g:loaded_commenter = 1

vnoremap <silent> gc :call commenter#toggle_op(mode())<cr>
nnoremap <silent> gc :<c-u>set opfunc=commenter#toggle_op<cr>g@
nnoremap <silent> gcc :<c-u>set opfunc=commenter#toggle_op<bar>exec 'norm!' v:count1.'g@_'<cr>

command! -nargs=0 -range -bang Comment <line1>,<line2>call s:comment(<q-bang>, <line1>, <line2>)
command! -nargs=0 -range -bang Uncomment call commenter#uncomment(<line1>, <line2>)

func! s:comment(bang, start, end) range
	if empty(a:bang)
		call commenter#comment(a:start, a:end)
	else
		call commenter#toggle(a:start, a:end)
	end
endf
