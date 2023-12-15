" ============================================================================
" File: search.vim
" Description: View all search matches at once
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:search_loaded') || &cp
    finish
end
let g:search_loaded = 1

func s:search(bang, pattern)
    let options = empty(a:bang) ? {} : {'exclude_syntax': []}
    call search#do(a:pattern, options)
endf

command -bang -nargs=? Search call <sid>search(<q-bang>, <q-args>)

let s:options = #{
    \ popup: 1,
    \ popup_borders: ["┌", "─" ,"┐", "│", "┘", "─", "└", "│" ],
    \ width_popup: "80%",
    \ max_height_popup: "90%",
    \ max_height_window: "50%",
    \ exclude_syntax: ['Comment', 'String'],
    \ set_search_register: 1,
    \ add_to_search_history: 1,
    \ show_line_numbers: 1,
    \ goto_closest_match: 1,
    \ left_padding: " ",
    \ show_match: 1,
    \ match_hl: "SearchUnderline",
    \ linenr_hl: "LineNr",
    \ transform_cb: v:null,
    \ filter_cb: v:null,
    \ mappings_jump: ['l', '<cr>', '<2-LeftMouse>'],
    \ mappings_close: ['q', '<esc>'],
    \ mappings_context: ['c'],
    \ mappings_toggle_numbers: ['a'],
\ }

func! _search_global_options()
    let globals = {}
    for option in keys(s:options)
        let globals[option] = get(g:, 'search_' . option)
    endfor
    return globals
endf

for [s:option, s:default] in items(s:options)
    let g:search_{s:option} = get(g:, 'search_'.s:option, s:default)
endfo
