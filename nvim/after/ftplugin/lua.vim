
setl noexpandtab
setl tabstop=3

nnoremap <silent> <buffer> - <cmd>call search#do('\v^([a-zA-Z_.]+ \= \|local )?function', #{
    \ show_match: 0,
    \ post_jump_cmd: "norm! zt10\<c-y>",
    \ matchadd: #{
        \ Keyword: '\<function\>'
    \ }
\ })<cr>