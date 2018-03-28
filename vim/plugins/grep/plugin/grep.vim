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

command! -nargs=* -bang Grep call grep#grep('grep', <q-args>)
command! -nargs=* -bang Grepa call grep#grep('grepadd', <q-args>)
command! -nargs=* -bang Greb call grep#grep_buffer('grep', <q-bang>, <q-args>)
command! -nargs=* -bang Greba call grep#grep_buffer('grepadd', <q-bang>, <q-args>)
command! -nargs=* -bang Search call grep#grep_buffer('vimgrep', <q-bang>, <q-args>)
