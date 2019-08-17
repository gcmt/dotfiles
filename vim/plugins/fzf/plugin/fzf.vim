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

command! -nargs=* -bang Files call fzf#files(<q-args>, <q-bang> == '!')
command! -nargs=0 -bang Lines call fzf#lines(<q-bang> == '!')

let s:options = {
	\ 'default_opts': "--multi --preview 'head -100 {}' --color fg+:18,bg+:24,hl+:1,hl:1,prompt:-1,pointer:-1,info:23,border:19",
	\ 'preview_treshold': 150,
	\ 'term_prg': 'TMUX= urxvt -name vim-popup',
\ }

for [s:option, s:default] in items(s:options)
	let g:fzf_{s:option} = get(g:, 'fzf_'.s:option, s:default)
endfo

