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

nnoremap <silent> j :call _smooth_scroll(1, 1, 1)<cr>
nnoremap <silent> k :call _smooth_scroll(-1, 1, 1)<cr>
