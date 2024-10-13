" ============================================================================
" File: fzf.vim
" Description: Simple fzf integration
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:fzf_loaded') || !executable('fzf') || &cp
    finish
end
let g:fzf_loaded = 1

command! -bang -nargs=* Files call fzf#files(<q-args>, !empty(<q-bang>))

let s:options = {
    \ 'expect': {
        \ 'ctrl-t': 'tab split',
        \ 'ctrl-s': 'split',
        \ 'ctrl-v': 'vsplit',
    \ },
    \ 'options': [
        \ "-e",
        \ "--multi",
        \ "--reverse",
        \ "--preview-window", "border-left",
        \ "--bind", "TAB:down,SHIFT-TAB:up",
        \ "--bind", "CTRL-N:toggle+down,CTRL-L:toggle+down,CTRL-H:toggle+up,RIGHT:toggle+down,LEFT:toggle+up",
        \ "--color", "fg+:18,bg+:24,hl+:1,hl:1,prompt:-1,pointer:-1,info:23,gutter:-1,border:22",
    \ ],
    \ 'preview_treshold': 150,
    \ 'preview_cmd': 'head -100 {}',
    \ 'term_cmd': 'TMUX= wezterm start --class wez-floating',
    \ 'tmux_cmd': 'tmux display-popup -E -w 90% -h 90% -y -1',
    \ 'files_cmd': "rg --files --hidden --no-require-git",
    \ 'files_cmd_bang': "rg --files --hidden --no-ignore"
\ }

for [s:option, s:default] in items(s:options)
    let g:fzf_{s:option} = get(g:, 'fzf_'.s:option, s:default)
endfo
