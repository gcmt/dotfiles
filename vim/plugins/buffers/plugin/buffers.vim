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
	\ sorting: 'alphabetical',
	\ cursorline: 1,
	\ maxheight: 80,
	\ maxwidth: 80,
	\ minwidth: 20,
	\ padding: [0, 1, 0, 1],
	\ label_unnamed: '[no name]',
	\ label_terminal: '[terminal]',
	\ line_format: '%{bufname} ‣ %{bufdetails}',
	\ popup: 1,
	\ popup_borderchars: ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
	\ popup_hl: 'Normal',
	\ popup_borderhl: ['LineNr'],
	\ popup_scrollbar: 1,
	\ popup_scrollbarhl: 'PMenuSBar',
	\ popup_thumbhl: 'PMenuThumb',
	\ popup_indicator: '',
	\ popup_indicatorhl: '',
	\ popup_cursorlinehl: 'PopupSelected',
	\ mappings: {
		\ 'q': '@quit',
		\ 't': '@tab',
		\ 's': '@split',
		\ 'v': '@vsplit',
		\ 'a': '@toggle_unlisted',
		\ 'd': '@bdelete',
		\ 'D': '@bdelete!',
		\ 'w': '@bwipe',
		\ 'W': '@wipe!',
		\ 'u': '@bunload',
		\ 'U': '@bunload!',
		\ 'l': '@edit',
		\ "\<cr>": '@edit',
	\ },
	\ popup_mappings: {
		\ 'K': ':norm! kk',
		\ 'J': ':norm! jj',
		\ 'g': ':norm! gg',
		\ 'G': ':norm! G',
	\ },
\ }

for [s:option, s:default] in items(s:options)
	let g:buffers_{s:option} = get(g:, 'buffers_'.s:option, s:default)
endfo

call prop_type_add('buffers_mod', {'highlight': 'Red'})
call prop_type_add('buffers_dim', {'highlight': 'Comment'})
call prop_type_add('buffers_listed', {'highlight': 'Fg'})
call prop_type_add('buffers_unlisted', {'highlight': 'Comment'})
call prop_type_add('buffers_terminal', {'highlight': 'Magenta'})
call prop_type_add('buffers_directory', {'highlight': 'Directory'})
