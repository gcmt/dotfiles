
setl keywordprg=:help
call setbufvar(bufnr('%'), '&cms', '" %s')

nnoremap <silent> <buffer> <leader>o :Grep! ^"\s\w<cr>

inoremap <silent> <buffer> <c-a> <c-r>=_jump_after('\v^\s*end\a*')<cr>
