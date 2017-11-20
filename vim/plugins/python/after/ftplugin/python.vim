
aug _python
	au!
	" remove empty lines at the end of the file
	au BufWritePre <buffer> call utils#s('\v($\n\s*)+%$', '', '')
aug END

iabbrev <buffer> none None
iabbrev <buffer> true True
iabbrev <buffer> false False

nnoremap <silent> <buffer> <f5> :!python %<cr>
inoremap <silent> <buffer> <f5> <esc>:!python %<cr>

" activate local virtualenv (default name  is 'venv')
command! -buffer -nargs=? Activate call python#venv#activate(<q-args>)

" generate tags
nnoremap <buffer> <f3> :TagMaker --languages=python -f .tags/python/0.project<cr>
nnoremap <buffer> <leader><f3> :TagMaker --languages=python -f .tags/python/X.package venv/**/package

" outline python module
nnoremap <silent> <buffer> <leader>o :Grep! ^\s*(class\\|def)\b<cr>

" expand current name into a function definition
inoremap <silent> <buffer> <c-c> <c-r>=python#snippets#func()<cr>

" Yapf
command! -range Yapf <line1>,<line2>call python#yapf#format()
nnoremap <silent> <buffer> <f4> :Yapf<cr>

" jedi integration
command! -buffer Usages call python#jedi#usages()
command! -buffer Docstring call python#jedi#docstring()
command! -buffer Signature call python#jedi#signature()
command! -bang -buffer -nargs=? Definition call python#jedi#definitions(<q-bang>, <q-args>)
command! -bang -buffer -nargs=? Assignment call python#jedi#assignments(<q-bang>, <q-args>)
nnoremap <silent> <buffer> <leader>k :Docstring<cr>
nnoremap <silent> <buffer> <leader>,u :Usages<cr>
nnoremap <silent> <buffer> <leader>,a :Assignment<cr>
nnoremap <silent> <buffer> <leader>,d :Definition<cr>
nnoremap <silent> <buffer> <leader>,s :Signature<cr>
inoremap <silent> <buffer> <c-x><c-s> <c-r>=python#jedi#call_signatures()<cr>
