" ============================================================================
" File: fm.vim
" Description: Simple vifm/ranger integration
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:fm_loaded') || &cp
	finish
end
let g:fm_loaded = 1

let fm = executable('vifm') ? 'vifm' : ''
let fm = empty(fm) && executable('ranger') ? 'ranger' : fm

if empty(fm)
	finish
end

command! -nargs=* -bang Fm call fm#open(fm, <q-args>, <q-bang> == '!')

let s:options = {
	\ 'preview_treshold': 150,
	\ 'term_prg': 'TMUX= urxvt -name vim-popup',
\ }

for [s:option, s:default] in items(s:options)
	let g:fm_{s:option} = get(g:, 'fm_'.s:option, s:default)
endfo
