
set wrap
setl nolist
setl nonumber
setl norelativenumber
setl textwidth=100

" break undo sequence
inoremap <buffer> . .<c-g>u
inoremap <buffer> ? ?<c-g>u
inoremap <buffer> ! !<c-g>u
inoremap <buffer> , ,<c-g>u
