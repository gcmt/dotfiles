
setl textwidth=88

" Outline python module
nnoremap <silent> <buffer> - :call search#do('\v^\s*\zs(class\|def)>', #{show_match: 0, transform_cb: {l -> trim(l, ':')}})<cr>
