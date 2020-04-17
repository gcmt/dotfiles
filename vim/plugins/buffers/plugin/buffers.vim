" ============================================================================
" File: buffers.vim
" Description: Buffers list
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:buffers_loaded') || &cp
	finish
end
let g:buffers_loaded = 1

command! -nargs=0 -bang Buffers call buffers#view(<q-bang> == '!')

let s:options = {
	\ 'max_height': 20,
\ }

for [s:option, s:default] in items(s:options)
	let g:buffers_{s:option} = get(g:, 'buffers_'.s:option, s:default)
endfo

if has('textprop')
	call prop_type_add('buffers_mod', {'highlight': 'Red'})
	call prop_type_add('buffers_dim', {'highlight': 'Comment'})
	call prop_type_add('buffers_listed', {'highlight': 'Normal'})
	call prop_type_add('buffers_unlisted', {'highlight': 'FgDim'})
	call prop_type_add('buffers_terminal', {'highlight': 'Blue'})
end
