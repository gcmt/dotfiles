
setl keywordprg=:help
call setbufvar(bufnr('%'), '&cms', '" %s')

nnoremap <silent> <buffer> <leader>o :Grep! ^"\s\w<cr>

