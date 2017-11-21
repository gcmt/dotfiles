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

command! -nargs=* -bang Grep call <sid>grep(<q-bang>, 'grep!', <q-args>)
command! -nargs=* -bang Grepa call <sid>grep(<q-bang>, 'grepadd!', <q-args>)

func! s:grep(bang, grepcmd, args)
	if empty(a:bang)
		call grep#run(a:grepcmd, a:args)
	else
		call grep#buffer(a:grepcmd, a:args)
	end
endf
