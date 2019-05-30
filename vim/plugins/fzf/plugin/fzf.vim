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

command! -nargs=* Fzf call fzf#search_files(<q-args>)

let s:options = {
	\ 'preview_treshold': 150,
	\ 'preview_cmd': 'head -100 {}',
\ }

for [s:option, s:default] in items(s:options)
	let g:fzf_{s:option} = get(g:, 'fzf_'.s:option, s:default)
endfo

