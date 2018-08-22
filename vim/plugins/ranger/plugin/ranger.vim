" ============================================================================
" File: ranger.vim
" Description: Simple ranger integration
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:ranger_loaded') || !executable('ranger') || &cp
	finish
end
let g:ranger_loaded = 1

command! -nargs=* -bang Ranger call ranger#open(<q-args>, <q-bang> == '!')

let s:options = {
	\ 'preview_treshold': 150,
	\ 'term_prg': 'TMUX= urxvt -name floating',
	\ 'bindings': {'l': 'window', 'ee': 'window', 'es': 'split', 'ev': 'vsplit', 'et': 'tab'},
\ }

for [s:option, s:default] in items(s:options)
	let g:ranger_{s:option} = get(g:, 'ranger_'.s:option, s:default)
endfo
