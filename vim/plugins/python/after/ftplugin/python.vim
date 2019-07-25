
iabbrev <buffer> none None
iabbrev <buffer> true True
iabbrev <buffer> false False

if exists('$TMUX')
	let b:tmux = {'prg': 'python'}
	nnoremap <silent> <buffer> <leader>r :call tmux#run_buffer()<cr>
	nnoremap <silent> <buffer> <leader>z :call tmux#exec('resizep -Z')<cr>
else
	nnoremap <silent> <buffer> <leader>r :python %<cr>
end

let s:breakpoint = "import pudb; pudb.set_trace()"

inoremap <silent> <buffer> <c-g><c-b> <c-r><c-o>=<sid>insert_breakpoint()<cr>
nnoremap <silent> <buffer> <leader>B :call <sid>delete_breakpoints()<cr>
nnoremap <silent> <buffer> <leader>b :call <sid>toggle_breakpoints()<cr>

func! s:insert_breakpoint()
	return s:breakpoint
endf

func! s:delete_breakpoints()
   let view = winsaveview()
	exec printf('keepj g/\V%s/del', s:breakpoint)
	call winrestview(view)
endf

func! s:toggle_breakpoints()
   let view = winsaveview()
	exec printf('keepj g/\V%s/norm gcc', s:breakpoint)
	call winrestview(view)
endf

" generate tags
nnoremap <buffer> <f3> :Ctags --languages=python -f .tags/python/0.project<cr>

" outline python module
nnoremap <silent> <buffer> <leader>o :Search! \v^\s*\zs(class\|def)><cr>

" expand current name into a function definition
inoremap <silent> <buffer> <c-g><c-s> <c-r>=python#snippets#func()<cr>

" Foramt code
command! Format call python#formatter#format_current_file()
nnoremap <silent> <buffer> <f4> :Format<cr>

" jedi integration
" command! -buffer Usages call python#jedi#usages()
" command! -buffer Docstring call python#jedi#docstring()
" command! -buffer Signature call python#jedi#signature()
" command! -bang -buffer -nargs=? Definition call python#jedi#definitions(<q-bang>, <q-args>)
" command! -bang -buffer -nargs=? Assignment call python#jedi#assignments(<q-bang>, <q-args>)
" nnoremap <silent> <buffer> <leader>k :Docstring<cr>
" nnoremap <silent> <buffer> <leader>,u :Usages<cr>
" nnoremap <silent> <buffer> <leader>,a :Assignment<cr>
" nnoremap <silent> <buffer> <leader>,d :Definition<cr>
" nnoremap <silent> <buffer> <leader>,s :Signature<cr>
" inoremap <silent> <buffer> <c-x><c-s> <c-r>=python#jedi#call_signatures()<cr>
