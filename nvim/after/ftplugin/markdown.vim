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

nnoremap <buffer> <silent> j :call _smooth_scroll(1, 1, 2)<cr>
nnoremap <buffer> <silent> k :call _smooth_scroll(-1, 1, 2)<cr>

nnoremap <buffer> <silent> J :call _smooth_scroll(1, 3, 4)<cr>
nnoremap <buffer> <silent> K :call _smooth_scroll(-1, 3, 4)<cr>
