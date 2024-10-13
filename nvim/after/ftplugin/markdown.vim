setl wrap
setl textwidth=0
setl linebreak
setl nolist
setl nonumber
setl norelativenumber
setl foldcolumn=1

" break undo sequence
inoremap <buffer> . .<c-g>u
inoremap <buffer> ? ?<c-g>u
inoremap <buffer> ! !<c-g>u
inoremap <buffer> , ,<c-g>u

imap <silent> <buffer> <c-t> <c-r>=trim(system("date +%Y-%m-%d"))<cr>

nnoremap <buffer> j <cmd>call _smooth_scroll(1, 1, 2)<cr>
nnoremap <buffer> k <cmd>call _smooth_scroll(-1, 1, 2)<cr>

nnoremap <buffer> J <cmd>call _smooth_scroll(1, 3, 4)<cr>
nnoremap <buffer> K <cmd>call _smooth_scroll(-1, 3, 4)<cr>

" Outline file
nnoremap <silent> <buffer> - <cmd>call search#do('\v^\zs(#+) ', #{
    \ show_match: 0,
    \ transform_cb: {l -> l},
    \ post_jump_cmd: "norm! zt10\<c-y>"
\ })<cr>
