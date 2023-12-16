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

" sorting: [alphabetical | numerical | viewtime | modtime]

let s:options = #{
    \ popup: 1,
    \ popup_borders: ["┌", "─" ,"┐", "│", "┘", "─", "└", "│" ],
    \ show_bookmarks: 1,
    \ sorting: 'alphabetical',
    \ cursorline: 1,
    \ max_height: 80,
    \ label_unnamed: '[no name]',
    \ label_terminal: '[terminal]',
    \ line_format: ' %{bufname}%(  %{bufpath}%)%(  [%{mark}]%)',
    \ fm_command: 'Explorer %f',
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
        \ "\<esc>": '@quit',
    \ },
\ }

for [s:option, s:default] in items(s:options)
    let g:buffers_{s:option} = get(g:, 'buffers_'.s:option, s:default)
endfo

func s:update_time_table()
    if empty(&buftype)
        let path = fnamemodify(bufname('%'), ':p')
        let g:buffers_viewtime_table[path] = strftime('%s')
    end
endf

func s:update_mod_table()
    if empty(&buftype)
        let path = fnamemodify(bufname('%'), ':p')
        let g:buffers_modtime_table[path] = strftime('%s')
    end
endf

" maps paths to their last view/mod time
let g:buffers_viewtime_table = {}
let g:buffers_modtime_table = {}

if g:buffers_sorting == 'viewtime'
    aug _buffers
        au!
        au BufWinEnter * call <sid>update_time_table()
    aug END
end

if g:buffers_sorting == 'modtime'
    aug _buffers
        au!
        au BufModifiedSet * call <sid>update_mod_table()
    aug END
end
