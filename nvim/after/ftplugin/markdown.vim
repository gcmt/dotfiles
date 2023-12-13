setl wrap
setl textwidth=0
setl linebreak
setl showbreak=
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
