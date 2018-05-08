" ============================================================================
" Description: Vim/Rofi integration
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if !executable('rofi') || exists('g:rofi_loaded') || &cp
	finish
end
let g:rofi_loaded = 1

let s:options = {
	\ 'width_rules': [['<100', 60], ['<90', 70], ['<80', 80], ['<70', 90]],
	\ 'default_width': 50,
	\ 'max_lines': 12,
	\ 'color_dim': 'Comment',
	\ 'color_mod': 'Red',
\ }

for [s:option, s:default] in items(s:options)
	let g:rofi_{s:option} = get(g:, 'rofi_'.s:option, s:default)
endfo

command -nargs=? RofiEdit call rofi#files#edit(<q-args>)
command -nargs=0 -bang RofiBuffers call rofi#buffers#show(<q-bang> != '!')
