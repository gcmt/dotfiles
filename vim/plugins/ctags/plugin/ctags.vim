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
	au VimEnter,BufWritePost * call s:run()
aug END

func s:run()
	if empty(&filetype) || !empty(&buftype)
		return
	end
	let dir = getcwd()
	let tagfile = call(g:ctags.tagfile, [])
	if !filereadable(ctags#joinpaths(dir, tagfile))
		return
	end
	let options  = call(g:ctags.options, [])
	let options += get(g:ctags, &filetype.'_options', [])
	call ctags#run(getcwd(), tagfile, options)
endf
