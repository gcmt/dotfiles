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

let s:options = #{
    \ popup: 1,
    \ popup_border: 'single',
    \ cursorline: 1,
    \ minheight: -1,
    \ maxheight: 80,
    \ mark_format: '%{pipes} %{mark} %{linenr} %{line}',
    \ file_format: '%{file}',
    \ highlight: {
        \ 'pipes': 'LineNr',
        \ 'mark': 'Blue',
        \ 'linenr': 'LineNr',
        \ 'colnr': 'LineNr',
        \ 'line': 'Fg',
        \ 'file': 'Magenta',
    \ },
    \ mappings: {
        \ 'q': '@quit',
        \ 't': '@tab',
        \ 's': '@split',
        \ 'v': '@vsplit',
        \ 'l': '@jump',
        \ 'd': '@delete',
        \ "\<cr>": '@jump',
        \ "\<esc>": '@quit',
    \ },
\ }


for [s:option, s:default] in items(s:options)
    let g:marks_{s:option} = get(g:, 'marks_'.s:option, s:default)
endfor

command! -nargs=0 Marks call marks#view()
command! -nargs=0 Mark call marks#set_auto(1)
command! -nargs=0 Markg call marks#set_auto(0)
