" ============================================================================
" File: fm.vim
" Description: Vifm integration
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:fm_loaded') || &cp
    finish
end
let g:fm_loaded = 1

command! -bang -nargs=* Vifm call vifm#open(<q-args>, <q-bang>)

let s:options = {
    \ 'preview_treshold': 150,
    \ 'term_cmd': 'TMUX= wezterm start --class wez-floating',
    \ 'tmux_cmd': 'tmux display-popup -E -w 90% -h 90%',
\ }

for [s:option, s:default] in items(s:options)
    let g:fm_{s:option} = get(g:, 'fm_'.s:option, s:default)
endfo
