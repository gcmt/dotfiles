" ============================================================================
" File: buffers.vim
" Description: Buffers list
" Author: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:buffers_loaded') || &cp
    finish
end
let g:buffers_loaded = 1

command! -nargs=0 -bang Buffers call buffers#view(<q-bang> == '!')

let s:options = #{
    \ show_bookmarks: 1,
    \ sorting: 'alphabetical',
    \ cursorline: 1,
    \ minheight: -1,
    \ maxheight: 80,
    \ label_unnamed: '[no name]',
    \ label_terminal: '[terminal]',
    \ line_format: ' %{bufname}%(  %{bufpath}%)%(  [%{mark}]%)',
    \ highlight: {
        \ "bufname": "Fg",
        \ 'bufpath': 'Comment',
        \ 'is_modified': 'Red',
        \ 'is_unlisted': 'Comment',
        \ 'is_terminal': 'Magenta',
        \ 'is_directory': 'Directory',
        \ 'mark': 'Comment',
    \ },
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
        \ '.': '@fm',
        \ "\<cr>": '@edit',
    \ },
\ }

for [s:option, s:default] in items(s:options)
    let g:buffers_{s:option} = get(g:, 'buffers_'.s:option, s:default)
endfo
