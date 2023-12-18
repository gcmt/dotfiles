" ============================================================================
" File: explorer.vim
" Description: Minimal file explorer
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:explorer_loaded') || &cp
    finish
end
let g:explorer_loaded = 1

command! -bang -nargs=? Explorer call explorer#open(<q-args>, <q-bang>)

let s:options = #{
    \ popup: 1,
    \ popup_border: 'single',
    \ width_popup: "80%",
    \ height_popup: "80%",
    \ height_window: "50%",
    \ hidden_files: 1,
    \ filters: [],
    \ filters_active: 1,
    \ expand_depth: 3,
\ }

for [s:option, s:default] in items(s:options)
    let g:explorer_{s:option} = get(g:, 'explorer_'.s:option, s:default)
endfo

let s:mappings = #{
    \ enter_or_edit:        [['l', '<cr>'], "Enter directory or edit file under cursor"],
    \ close:                [['q', '<esc>'], "Close this window"],
    \ info:                 [['i'], "Show file or directory info"],
    \ preview:              [['p'], "Preview file under cursor"],
    \ auto_expand:          [['x'], "Auto expand directories"],
    \ close_dir:            [['h'], "Close current directory"],
    \ set_root:             [['L'], "Set current directory as root"],
    \ up_root:              [['H'], "Set the parent directory as root"],
    \ set_cwd:              [['w'], "Set working directory"],
    \ toggle_hidden_files:  [['a'], "Toggle hidden files"],
    \ toggle_filters:       [['f'], "Toggle filters"],
    \ create_file:          [['%'], "Create new file"],
    \ create_dir:           [['c'], "Create new directory"],
    \ rename:               [['r'], "Rename file or directory under cursor"],
    \ delete:               [['d'], "Delete file or directory under cursor"],
    \ set_bookmark:         [['m'], "Set bookmark for the file or directory under cursor"],
    \ del_bookmark:         [['M'], "Delete bookmark for the file or directory under cursor"],
    \ help:                 [['?'], "Show help"],
\ }

for [s:action, s:default] in items(s:mappings)
    let g:explorer_map_{s:action} = get(g:, 'explorer_map_'.s:action, s:default[0])
endfo

let s:colors = #{
    \ title: 'Magenta',
    \ pipe: 'Comment',
    \ dir: 'Blue',
    \ link: 'Cyan',
    \ exec: 'Green',
    \ mark: 'Comment',
\ }

for [s:hl, s:hlgroup] in items(s:colors)
    let g:explorer_hl_{s:hl} = get(g:, 'explorer_hl_'.s:hl, s:hlgroup)
endfo

" Returns all mappings with their help message
func! __explorer_mappings_help()
    let help = []
    for [action, default] in items(s:mappings)
        let mappings = get(g:, 'explorer_map_' . action)
        let help_msg = default[1]
        call add(help, [mappings, help_msg])
    endfo
    return help
endf

" Returns all mappings
func! __explorer_mappings()
    let mappings = {}
    for action in keys(s:mappings)
        let mappings[action] = get(g:, 'explorer_map_' . action)
    endfor
    return mappings
endf
