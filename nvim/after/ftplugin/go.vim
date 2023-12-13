nmap <buffer> <leader>r <plug>(go-run)
nmap <buffer> <leader>b <plug>(go-build)
nmap <buffer> <leader>t <plug>(go-test)
nmap <buffer> <leader>i <plug>(go-implements)
nmap <buffer> <leader>d <plug>(go-doc)
nmap <buffer> <leader>c <plug>(go-coverage-toggle)
nmap <buffer> <leader>f <plug>(go-fmt)

au BufWritePre,FileWritePre <buffer> GoFmt

nmap <buffer> } :call search('\V\({\\|}\)', 'Wz')<cr>
nmap <buffer> { :call search('\V\({\\|}\)', 'Wbz')<cr>

" Outline file
nnoremap <silent> <buffer> - :call search#do('\v^\s*\zs(func\|type)', #{show_match: 0, transform_cb: {l -> trim(l, '{')}})<cr>
