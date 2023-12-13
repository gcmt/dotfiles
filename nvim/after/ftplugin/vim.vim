
setl keywordprg=:help
call setbufvar(bufnr('%'), '&cms', '" %s')

nnoremap <silent> <buffer> - :call search#do('\v^\s*\zsfun', #{show_match: 0})<cr>
