
setl noexpandtab
setl tabstop=3
setl shiftwidth=0
setl softtabstop=0

call matchadd('Comment', '"""')
call matchadd('Special', '\v(\@doc|\@spec)')
call matchadd('Statement', '\vdo:')

nnoremap <silent> <buffer> <f5> :!elixir %<cr>
inoremap <silent> <buffer> <f5> <esc>:!elixir %<cr>

nmap <silent> <leader>k K
nnoremap <silent> <leader>,d :ExDef<cr>
