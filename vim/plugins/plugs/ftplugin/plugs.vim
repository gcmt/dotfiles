
nnoremap <silent> <buffer> q :close<cr>
nnoremap <silent> <buffer> d :call plugs#actions#delete()<cr>
nnoremap <silent> <buffer> i :call plugs#actions#install()<cr>
nnoremap <silent> <buffer> I :call plugs#actions#install_all()<cr>
nnoremap <silent> <buffer> u :call plugs#actions#update()<cr>
nnoremap <silent> <buffer> U :call plugs#actions#update_all()<cr>
