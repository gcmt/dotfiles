" ============================================================================
" File: tmux.vim
" Description: Tmux vim interop
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:tmux_loaded') || &cp
	finish
end
let g:tmux_loaded = 1

let s:options = {}

for [s:option, s:default] in items(s:options)
	let g:tmux_{s:option} = get(g:, 'tmux_'.s:option, s:default)
endfor

