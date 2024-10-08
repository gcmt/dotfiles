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
    \ marks: "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890!@#$%^&*()_+-=[]{};:\",./<>?\|`~'",
    \ popup: 1,
    \ popup_border: 'single',
    \ width_popup: "70%",
    \ height_popup: "80%",
    \ height_window: "50%",
    \ cursorline: 1,
    \ explorer_cmd: 'Explorer %f',
    \ mappings_jump: ['l', '<enter>'],
    \ mappings_unset: ['dd'],
    \ mappings_change: ['c'],
    \ mappings_close: ['q', '<esc>'],
    \ mappings_toggle_global: ['a'],
    \ hl_title: 'Magenta',
    \ hl_mark: 'Magenta',
    \ hl_file: 'Fg',
    \ hl_dir: 'Blue',
    \ hl_dim: 'Comment',
\ }

for [s:option, s:default] in items(s:options)
    let g:bookmarks_{s:option} = get(g:, 'bookmarks_'.s:option, s:default)
endfor

command! -nargs=1 Jump call bookmarks#jump(<q-args>)
command! -bang -nargs=0 Bookmarks call bookmarks#view(!empty(<q-bang>))
command! -bang -nargs=0 QuickJump call bookmarks#quickjump(!empty(<q-bang>))
command! -nargs=1 MarkFile call bookmarks#set(<q-args>, expand("%:p"))
command! -nargs=1 MarkDir call bookmarks#set(<q-args>, expand("%:p:h"))
