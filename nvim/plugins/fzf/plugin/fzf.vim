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

command! -bang -nargs=* Files call fzf#files(<q-args>, <q-bang>)

let s:options = {
    \ 'expect': {
        \ 'ctrl-t': 'tab split',
        \ 'ctrl-s': 'split',
        \ 'ctrl-v': 'vsplit',
    \ },
    \ 'options': [
        \ "-e",
        \ "--multi",
        \ "--layout=reverse",
        \ "--color", "fg+:18,bg+:24,hl+:1,hl:1,prompt:-1,pointer:-1,info:23,border:19,gutter:-1",
    \ ],
    \ 'preview_treshold': 150,
    \ 'preview_cmd': 'head -100 {}',
    \ 'term_cmd': 'TMUX= kitty --name vim-popup',
    \ 'tmux_cmd': 'tmux display-popup -E -w 90% -h 90%',
    \ 'files_cmd': "rg --files --no-hidden",
    \ 'files_cmd_bang': "rg --files --hidden -g '!.git/' -g '!.venv/' -g '!.mypy_cache/' -g '!.ruff_cache/' -g '!node_modules/'",
\ }

for [s:option, s:default] in items(s:options)
    let g:fzf_{s:option} = get(g:, 'fzf_'.s:option, s:default)
endfo
