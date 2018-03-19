" =============================================================================
" File: ctags.vim
" Description: Simple wrapper around ctags
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

if !has('job') || !executable('ctags') || exists("g:loaded_ctags") || &cp
	finish
end
let g:loaded_ctags = 1

command -nargs=* -bang Ctags call <sid>ctags(<q-bang>, <q-args>)

func s:ctags(bang, args)
	if empty(a:bang)
		call ctags#sync(a:args)
	else
		call ctags#async(a:args)
	end
endf

" Automatically generate tags for the current project, but only when
" there are some tagfiles already

aug _ctags
	au VimEnter,BufWritePost * call <sid>auto()
aug END

func s:auto()
	let tagfiles = glob('.tags/'.&ft.'/*', 1, 1)
	if empty(&filetype) || empty(tagfiles)
		return
	end
	let output = '.tags/'.&ft.'/0.project'
	let options = get(g:, 'ctags_'.&ft.'_options', '')
	exec 'Ctags!' '--languages='.&ft '-f' output options
endf
