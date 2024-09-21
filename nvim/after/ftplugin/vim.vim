
setl keywordprg=:help
call setbufvar(bufnr('%'), '&cms', '" %s')

nnoremap <silent> <buffer> - <cmd>call search#do('\v^\s*\zsfun', #{
    \ show_match: 0,
    \ post_jump_cmd: "norm! zt10\<c-y>"
\ })<cr>
