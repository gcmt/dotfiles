
setl noexpandtab
setl tabstop=3

setl keywordprg=:help
call setbufvar(bufnr('%'), '&cms', '" %s')

nnoremap <silent> <buffer> <leader>o :Search! \v^\s*\zsfun<cr>

inoremap <silent> <buffer> <c-a> <c-r>=_jump_after('\v^\s*end\a*')<cr>
