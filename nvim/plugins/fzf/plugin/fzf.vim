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

command! -nargs=* Files call fzf#files(<q-args>)
command! -nargs=0 Lines call fzf#lines()

let s:options = {
    \ 'default_opts': "-e --multi --preview 'head -100 {}' --color fg+:18,bg+:24,hl+:1,hl:1,prompt:-1,pointer:-1,info:23,border:19,gutter:-1",
    \ 'preview_treshold': 150,
    \ 'term_prg': 'TMUX= urxvt -name vim-popup',
    \ 'files_cmd': "rg --files --hidden -g '!.git/' -g '!.venv/'  -g '!.mypy_cache/'",
\ }

for [s:option, s:default] in items(s:options)
    let g:fzf_{s:option} = get(g:, 'fzf_'.s:option, s:default)
endfo

