" =============================================================================
" File: ctags.vim
" Description: Automatic ctags after every save
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

if !has('job') || !executable('ctags') || exists("g:loaded_ctags") || &cp
	finish
end
let g:loaded_ctags = 1

let g:ctags = extend(get(g:, 'ctags', {}), {
	\ 'options': {-> ['-Rn', '--languages='.&filetype]},
	\ 'tagfile': {-> isdirectory('.tags') ? printf('.tags/%s/0.project', &ft) : 'tags'},
\ }, 'force')

aug _ctags
	au VimEnter,BufWritePost * call ctags#run()
aug END
