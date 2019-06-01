" ============================================================================
" File: fzf.vim
" Description: Simple fzf integration
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:fzf_loaded') || !executable('fzf') || &cp
	finish
end
let g:fzf_loaded = 1

command! -nargs=* Files call fzf#files(<q-args>)
command! -nargs=0 Lines call fzf#lines()

let s:options = {
\ }

for [s:option, s:default] in items(s:options)
	let g:fzf_{s:option} = get(g:, 'fzf_'.s:option, s:default)
endfo

