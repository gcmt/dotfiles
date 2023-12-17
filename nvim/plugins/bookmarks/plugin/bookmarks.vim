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
    \ marks: "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890!@#$%^&*()_+-=[]{};:\",./<>?\|`~'",
    \ explorer_cmd: 'Explorer %f',
    \ mappings_jump: ['l', '<enter>'],
    \ mappings_unset: ['dd'],
    \ mappings_change: ['c'],
    \ mappings_close: ['q', '<esc>'],
    \ mappings_toggle_global: ['a'],
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
command! -nargs=1 Mark call bookmarks#set(<q-args>, expand("%:p"))
command! -nargs=1 MarkDir call bookmarks#set(<q-args>, expand("%:p:h"))
