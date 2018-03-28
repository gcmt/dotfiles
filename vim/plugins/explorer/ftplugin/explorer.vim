
nnoremap <silent> <buffer> q :bdelete<cr>

nnoremap <silent> <buffer> l :call explorer#actions#enter_or_edit()<cr>
nnoremap <silent> <buffer> <right> :call explorer#actions#enter_or_edit()<cr>
nnoremap <silent> <buffer> <enter> :call explorer#actions#enter_or_edit()<cr>

nnoremap <silent> <buffer> h :call explorer#actions#up_dir()<cr>
nnoremap <silent> <buffer> <left> :call explorer#actions#up_dir()<cr>

nnoremap <silent> <buffer> a :call explorer#actions#toggle_hidden_files()<cr>

nnoremap <silent> <buffer> % :call explorer#actions#create_file()<cr>
nnoremap <silent> <buffer> c :call explorer#actions#create_directory()<cr>

nnoremap <silent> <buffer> r :call explorer#actions#rename()<cr>
nnoremap <silent> <buffer> d :call explorer#actions#delete()<cr>

nnoremap <silent> <buffer> mm :call explorer#actions#mark_toggle()<cr>
vnoremap <silent> <buffer> m :call explorer#actions#mark_toggle()<cr>
nnoremap <silent> <buffer> mp :call explorer#actions#print_marked_files()<cr>
nnoremap <silent> <buffer> mc :call explorer#actions#clear_marked_files()<cr>

nnoremap <silent> <buffer> gg :call explorer#buffer#goto_first_file()<cr>
nnoremap <silent> <buffer> G :call explorer#buffer#goto_last_file()<cr>

nnoremap <silent> <buffer> b :call explorer#actions#bookmarks_set(getchar())<cr>

nnoremap <silent> <buffer> ? :call explorer#actions#help()<cr>
