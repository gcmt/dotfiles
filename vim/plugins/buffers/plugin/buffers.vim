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

command! -nargs=0 Buffers call buffers#open()

let s:options = {
	\ 'max_winsize': 50,
\ }

for [s:option, s:default] in items(s:options)
	let g:buffers_{s:option} = get(g:, 'buffers_'.s:option, s:default)
endfo

func s:setup_colors()
	hi default link BuffersDim Comment
endf

call s:setup_colors()

aug _buffers
	au BufWritePost .vimrc call <sid>setup_colors()
	au Colorscheme * call <sid>setup_colors()
aug END
