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
command! -nargs=0 Mark call marks#set_auto(1)
command! -nargs=0 Markg call marks#set_auto(0)

func s:setup_colors()
	hi default link MarksMark Blue
	hi default link MarksFile Magenta
	hi default link MarksLine Normal
	hi default link MarksColNr LineNr
	hi default link MarksLineNr LineNr
	hi default link MarksPipe Comment
endf

call s:setup_colors()

aug _marks
	au BufWritePost .vimrc call <sid>setup_colors()
	au Colorscheme * call <sid>setup_colors()
aug END
