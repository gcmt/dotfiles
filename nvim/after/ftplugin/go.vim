
nmap <buffer> } <cmd>call search('\V\({\\|}\)', 'Wz')<cr>
nmap <buffer> { <cmd>call search('\V\({\\|}\)', 'Wbz')<cr>

" Outline file
nnoremap <silent> <buffer> - <cmd>call search#do('\v^\zs(func\|type) ', #{
    \ show_match: 0,
    \ transform_cb: {l -> trim(l, '{')},
    \ post_jump_cmd: "norm! zt10\<c-y>"
\ })<cr>
