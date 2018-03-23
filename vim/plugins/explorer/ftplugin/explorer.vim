
nnoremap <silent> <buffer> q :bdelete<cr>

nnoremap <silent> <buffer> l :call explorer#actions#enter_or_edit()<cr>
nnoremap <silent> <buffer> <right> :call explorer#actions#enter_or_edit()<cr>
nnoremap <silent> <buffer> <enter> :call explorer#actions#enter_or_edit()<cr>

nnoremap <silent> <buffer> h :call explorer#actions#up_dir()<cr>
nnoremap <silent> <buffer> <left> :call explorer#actions#up_dir()<cr>

nnoremap <silent> <buffer> a :call explorer#actions#toggle_hidden_files()<cr>

nnoremap <silent> <buffer> % :call explorer#actions#create_file()<cr>
nnoremap <silent> <buffer> c :call explorer#actions#create_directory()<cr>

nnoremap <silent> <buffer> d :call explorer#actions#delete()<cr>

nnoremap <silent> <buffer> gg :call explorer#buffer#goto_first_file()<cr>
nnoremap <silent> <buffer> G :call explorer#buffer#goto_last_file()<cr>

nnoremap <silent> <buffer> m :call explorer#actions#set_mark(getchar())<cr>
