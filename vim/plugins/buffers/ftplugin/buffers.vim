
nnoremap <silent> <buffer> q :close<cr>

nnoremap <silent> <buffer> a :call buffers#actions#toggle_unlisted()<cr>

nnoremap <silent> <buffer> <enter> :call buffers#actions#edit('current')<cr>
nnoremap <silent> <buffer> <c-j> :call buffers#actions#edit('current')<cr>
nnoremap <silent> <buffer> l :call buffers#actions#edit('current')<cr>
nnoremap <silent> <buffer> t :call buffers#actions#edit('tab')<cr>
nnoremap <silent> <buffer> s :call buffers#actions#edit('split')<cr>
nnoremap <silent> <buffer> v :call buffers#actions#edit('vsplit')<cr>

nnoremap <silent> <buffer> d :call buffers#actions#delete('bdelete')<cr>
nnoremap <silent> <buffer> D :call buffers#actions#delete('bdelete!')<cr>
nnoremap <silent> <buffer> w :call buffers#actions#delete('bwipe')<cr>
nnoremap <silent> <buffer> W :call buffers#actions#delete('bwipe!')<cr>
nnoremap <silent> <buffer> u :call buffers#actions#delete('bunload')<cr>
nnoremap <silent> <buffer> U :call buffers#actions#delete('bunload!')<cr>
