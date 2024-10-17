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

nnoremap <silent> j <cmd>call util#smooth_scroll(1, 2)<cr>
nnoremap <silent> k <cmd>call util#smooth_scroll(-1, 2)<cr>

nnoremap <silent> J <cmd>call util#smooth_scroll(1, 4, 3)<cr>
nnoremap <silent> K <cmd>call util#smooth_scroll(-1, 4, 3)<cr>
