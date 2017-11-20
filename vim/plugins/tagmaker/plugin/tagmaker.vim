" =============================================================================
" File: tagmaker.vim
" Description: Async tag generation
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

if !has('job') || !executable('ctags') || exists("g:loaded_tagmaker") || &cp
	finish
end
let g:loaded_tagmaker = 1

command -nargs=* -bang TagMaker call <sid>tagmaker(<q-bang>, <q-args>)

aug _tagmaker
	au VimEnter,BufWritePost * call <sid>auto()
aug END

func s:tagmaker(bang, args)
	if empty(a:bang)
		call tagmaker#sync(a:args)
	else
		call tagmaker#async(a:args)
	end
endf

" Automatically generate tags for the current project, but only when
" there are already some generated tagfiles
func s:auto()
	if getcwd() == $HOME
		return
	end
	let output = '.tags/'.&ft.'/0.project'
	let tagfiles = glob('.tags/'.&ft.'/*', 1, 1)
	if !empty(tagfiles)
		exec 'TagMaker!' '--languages='.&ft '-f' output
	end
endf
