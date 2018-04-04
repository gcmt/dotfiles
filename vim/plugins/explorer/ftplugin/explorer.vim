
nnoremap <silent> <buffer> q :sil bdelete<cr>

nnoremap <silent> <buffer> i :call explorer#actions#show_info()<cr>
nnoremap <silent> <buffer> p :call explorer#actions#preview()<cr>

nnoremap <silent> <buffer> l :call explorer#actions#enter_or_edit()<cr>
nnoremap <silent> <buffer> <enter> :call explorer#actions#enter_or_edit()<cr>

nnoremap <silent> <buffer> h :call explorer#actions#close_dir()<cr>

nnoremap <silent> <buffer> L :call explorer#actions#set_root()<cr>
nnoremap <silent> <buffer> H :call explorer#actions#up_root()<cr>

nnoremap <silent> <buffer> a :call explorer#actions#toggle_hidden_files()<cr>
nnoremap <silent> <buffer> f :call explorer#actions#toggle_filters()<cr>

nnoremap <silent> <buffer> % :call explorer#actions#create_file()<cr>
nnoremap <silent> <buffer> c :call explorer#actions#create_directory()<cr>

nnoremap <silent> <buffer> r :call explorer#actions#rename()<cr>
nnoremap <silent> <buffer> d :call explorer#actions#delete()<cr>

nnoremap <silent> <buffer> b :call explorer#actions#bookmarks_set(getchar())<cr>

nnoremap <silent> <buffer> ? :call explorer#actions#help()<cr>
