" =============================================================================
" File: ctags.vim
" Description: Automatic ctags after every save
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

if !has('job') || exists("g:loaded_ctags") || &cp
	finish
end
if !executable('ctags')
	finish
end
let g:loaded_ctags = 1

aug _ctags
	au VimEnter,BufWritePost * call ctags#run()
aug END
