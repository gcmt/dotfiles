
set wrap
setl nolist
setl nonumber
setl norelativenumber
setl textwidth=0

setl expandtab
setl tabstop=4

" break undo sequence
inoremap <buffer> . .<c-g>u
inoremap <buffer> ? ?<c-g>u
inoremap <buffer> ! !<c-g>u
inoremap <buffer> , ,<c-g>u

imap <silent> <buffer> <c-t> <c-r>=trim(system("date +%Y-%m-%d"))<cr>
