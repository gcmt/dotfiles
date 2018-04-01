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

let g:ctags_auto = get(g:, 'ctags_auto', {
	\ 'tagfile': {-> isdirectory('.tags') ? printf('.tags/%s/0.project', &ft) : 'tags'},
\ })

aug _ctags
	au VimEnter,BufWritePost * call <sid>auto()
aug END

func s:auto()
	if empty(&filetype)
		return
	end
	let tagfile = call(g:ctags_auto.tagfile, [])
	if filereadable(tagfile)
		exec 'Ctags!' '--languages='.&filetype '-f' tagfile
	end
endf
