setl wrap
setl textwidth=0
setl linebreak
setl nolist
setl nonumber
setl norelativenumber
setl foldcolumn=1
setl conceallevel=0

" break undo sequence
inoremap <buffer> . .<c-g>u
inoremap <buffer> ? ?<c-g>u
inoremap <buffer> ! !<c-g>u
inoremap <buffer> , ,<c-g>u

nnoremap <buffer> j <cmd>call util#smooth_scroll(1, 2)<cr>
nnoremap <buffer> k <cmd>call util#smooth_scroll(-1, 2)<cr>

nnoremap <buffer> J <cmd>call util#smooth_scroll(1, 4, 3)<cr>
nnoremap <buffer> K <cmd>call util#smooth_scroll(-1, 4, 3)<cr>

" Outline file
nnoremap <silent> <buffer> - <cmd>call search#do('\v^\zs(#+) ', #{
    \ show_match: 0,
    \ transform_cb: {l -> l},
    \ post_jump_cmd: "norm! zt10\<c-y>"
\ })<cr>

nnoremap <leader>m <cmd>Glare<cr>
