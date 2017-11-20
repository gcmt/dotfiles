
nnoremap <silent> <buffer> <enter> :call explorer#enter_or_edit()<cr>
nnoremap <silent> <buffer> <c-j> :call explorer#enter_or_edit()<cr>
nnoremap <silent> <buffer> <right> :call explorer#enter_or_edit()<cr>
nnoremap <silent> <buffer> l :call explorer#enter_or_edit()<cr>

nnoremap <silent> <buffer> <left> :call explorer#up_dir()<cr>
nnoremap <silent> <buffer> h :call explorer#up_dir()<cr>

nnoremap <silent> <buffer> a :call explorer#toggle_hidden_files()<cr>
