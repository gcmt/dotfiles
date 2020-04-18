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

let s:options = #{
	\ maxheight: 80,
	\ maxwidth: 80,
	\ popup: 1,
	\ popup_hl: 'Bg',
	\ popup_borderhl: ['FgVeryDim'],
	\ popup_scrollbar: 1,
	\ popup_scrollbarhl: 'PMenuSBar',
	\ popup_thumbhl: 'PMenuThumb',
	\ label_unnamed: '[no name]',
	\ label_terminal: '[terminal]',
\ }

for [s:option, s:default] in items(s:options)
	let g:buffers_{s:option} = get(g:, 'buffers_'.s:option, s:default)
endfo

if has('textprop')
	call prop_type_add('buffers_mod', {'highlight': 'Red', 'combine': 1})
	call prop_type_add('buffers_dim', {'highlight': 'Comment', 'combine': 1})
	call prop_type_add('buffers_listed', {'highlight': 'Normal', 'combine': 1})
	call prop_type_add('buffers_unlisted', {'highlight': 'Comment', 'combine': 1})
	call prop_type_add('buffers_terminal', {'highlight': 'Directory', 'combine': 1})
end
