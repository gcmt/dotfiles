
nmap <buffer> } :call search('\V\({\\|}\)', 'Wz')<cr>
nmap <buffer> { :call search('\V\({\\|}\)', 'Wbz')<cr>

" Outline file
nnoremap <silent> <buffer> - :call search#do('\v^\s*\zs(func\|type)', #{
    \ show_match: 0,
    \ transform_cb: {l -> trim(l, '{')},
    \ post_jump_cmd: "norm! zt10\<c-y>"
\ })<cr>
