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

let s:options = {
	\ 'max_winsize': 50,
\ }

for [s:option, s:default] in items(s:options)
	let g:marks_{s:option} = get(g:, 'marks_'.s:option, s:default)
endfor

command! -nargs=0 Marks call marks#view()
command! -nargs=0 MarkAuto call marks#set_auto()

func s:setup_colors()
	hi default link MarksMark Magenta
	hi default link MarksFile Blue
	hi default link MarksLine Normal
	hi default link MarksColNr Comment
	hi default link MarksLineNr Comment
	hi default link MarksLink Special
endf

call s:setup_colors()

aug _marks
	au BufWritePost .vimrc call <sid>setup_colors()
	au Colorscheme * call <sid>setup_colors()
aug END
