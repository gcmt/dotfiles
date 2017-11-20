" =============================================================================
" File: bookmarks.vim
" Description: File marks for quick navigation
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

if exists("g:loaded_bookmarks") || &cp
	finish
end
let g:loaded_bookmarks = 1

let s:options = {
	\ 'max_winsize': 50,
	\ 'marks': 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM'
\ }

for [s:option, s:default] in items(s:options)
	let g:bookmarks_{s:option} = get(g:, 'bookmarks_'.s:option, s:default)
endfor

command! -nargs=1 Jump call bookmarks#jump(<q-args>)
command! -nargs=0 Bookmarks call bookmarks#view_marks()
command! -nargs=1 MarkFile call bookmarks#set(<q-args>, expand("%:p"))
command! -nargs=1 MarkDir call bookmarks#set(<q-args>, expand("%:p:h"))

func s:setup_colors()
	hi default link BookmarksMark Magenta
	hi default link BookmarksFileTail Blue
	hi default link BookmarksDirTail Cyan
	hi default link BookmarksDim Comment
endf

call s:setup_colors()

aug _bookmarks
	au BufWritePost .vimrc call <sid>setup_colors()
	au Colorscheme * call <sid>setup_colors()
aug END
