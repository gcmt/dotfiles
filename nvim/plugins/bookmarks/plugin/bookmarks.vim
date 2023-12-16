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

let s:options = #{
    \ file: "$XDG_DATA_HOME/nvim/bookmarks.json",
    \ popup: 1,
    \ popup_borders: ["┌", "─" ,"┐", "│", "┘", "─", "└", "│" ],
    \ cursorline: 1,
    \ max_height: 50,
    \ marks: 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM',
    \ explorer_cmd: 'Explorer %f',
    \ mappings_jump: ['l', '<enter>'],
    \ mappings_unset: ['dd'],
    \ mappings_close: ['q', '<esc>'],
\ }

for [s:option, s:default] in items(s:options)
    let g:bookmarks_{s:option} = get(g:, 'bookmarks_'.s:option, s:default)
endfor

command! -nargs=1 Jump call bookmarks#jump(<q-args>)
command! -nargs=0 Bookmarks call bookmarks#view()
command! -nargs=1 MarkFile call bookmarks#set(<q-args>, expand("%:p"))
command! -nargs=1 MarkDir call bookmarks#set(<q-args>, expand("%:p:h"))

func s:setup_colors()
    hi default link BookmarksMark Magenta
    hi default link BookmarksFile Fg
    hi default link BookmarksDir Blue
    hi default link BookmarksDim Comment
endf

call s:setup_colors()

aug _bookmarks
    au BufWritePost */nvim/init.vim call <sid>setup_colors()
    au Colorscheme * call <sid>setup_colors()
aug END
