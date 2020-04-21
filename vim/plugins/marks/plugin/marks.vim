" =============================================================================
" File: marks.vim
" Description: Marks enhanced
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

if exists("g:loaded_marks") || &cp
	finish
end
let g:loaded_marks = 1

let s:options = #{
	\ cursorline: 1,
	\ maxheight: 80,
	\ maxwidth: 80,
	\ minwidth: 20,
	\ padding: [0, 1, 0, 1],
	\ line_format: '{link} {mark} {linenr} {line}',
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
		\ 'l': '@jump',
		\ 'd': '@delete',
		\ "\<cr>": '@jump',
	\ },
	\ popup_mappings: {
		\ 'K': ':norm! kk',
		\ 'J': ':norm! jj',
		\ 'g': ':norm! gg',
		\ 'G': ':norm! G',
	\ },
\ }


for [s:option, s:default] in items(s:options)
	let g:marks_{s:option} = get(g:, 'marks_'.s:option, s:default)
endfor

command! -nargs=0 Marks call marks#view()
command! -nargs=0 Mark call marks#set_auto(1)
command! -nargs=0 Markg call marks#set_auto(0)

call prop_type_add('marks_letter', {'highlight': 'Blue'})
call prop_type_add('marks_file', {'highlight': 'Magenta'})
call prop_type_add('marks_line', {'highlight': 'Normal'})
call prop_type_add('marks_linenr', {'highlight': 'LineNr'})
call prop_type_add('marks_link', {'highlight': 'Comment'})
