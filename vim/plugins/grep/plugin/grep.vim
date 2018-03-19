" =============================================================================
" File: grep.vim
" Description: Grep wrapper
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

if exists("g:loaded_grep") || &cp
	finish
end
let g:loaded_grep = 1

if executable('rg')
	set grepprg=rg\ -S\ -H\ --no-heading\ --vimgrep\ $*
	set grepformat=%f:%l:%c:%m
else
	set grepprg=grep\ -nrH\ $*
	set grepformat=%f:%l:%m
end

command! -nargs=* -bang Grep call grep#run('grep!', <q-args>)
command! -nargs=* -bang Grepa call grep#run('grepadd!', <q-args>)
command! -nargs=* -bang Greb call grep#run_buffer(<q-bang>, 'grep!', <q-args>)
command! -nargs=* -bang Greba call grep#run_buffer(<q-bang>, 'grepadd!', <q-args>)
