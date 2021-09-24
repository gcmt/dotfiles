
setl wrap
setl textwidth=0
setl linebreak
setl showbreak=
setl nolist
setl nonumber
setl norelativenumber
setl foldcolumn=1

setl expandtab
setl tabstop=2
setl shiftwidth=2
setl softtabstop=2

" break undo sequence
inoremap <buffer> . .<c-g>u
inoremap <buffer> ? ?<c-g>u
inoremap <buffer> ! !<c-g>u
inoremap <buffer> , ,<c-g>u
