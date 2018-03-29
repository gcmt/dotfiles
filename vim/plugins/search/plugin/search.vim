" ============================================================================
" File: search.vim
" Description: View all search matches at once
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:search_loaded') || &cp
	finish
end
let g:search_loaded = 1

command! -bang -nargs=* Search call search#do(<q-bang>, <q-args>)

let g:search_history = []

let s:options = {
	\ 'max_winsize': 50,
	\ 'exclude_syn': ['Comment', 'String'],
\ }

for [s:option, s:default] in items(s:options)
	let g:search_{s:option} = get(g:, 'search_'.s:option, s:default)
endfo
