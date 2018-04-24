
nnoremap <silent> <buffer> q :close<cr>

nnoremap <silent> <buffer> a :call buffers#actions#toggle_unlisted()<cr>zz

nnoremap <silent> <buffer> <enter> :call buffers#actions#edit('edit')<cr>zz
nnoremap <silent> <buffer> <c-j> :call buffers#actions#edit('edit')<cr>zz
nnoremap <silent> <buffer> l :call buffers#actions#edit('edit')<cr>zz
nnoremap <silent> <buffer> e :call buffers#actions#edit('edit')<cr>zz
nnoremap <silent> <buffer> o :call buffers#actions#edit('edit')<cr>zz
nnoremap <silent> <buffer> t :call buffers#actions#edit('tabedit')<cr>zz
nnoremap <silent> <buffer> s :call buffers#actions#edit('split')<cr>zz
nnoremap <silent> <buffer> v :call buffers#actions#edit('vsplit')<cr>zz

nnoremap <silent> <buffer> d :call buffers#actions#delete('bdelete')<cr>
nnoremap <silent> <buffer> D :call buffers#actions#delete('bdelete!')<cr>
nnoremap <silent> <buffer> w :call buffers#actions#delete('bwipe')<cr>
nnoremap <silent> <buffer> W :call buffers#actions#delete('bwipe!')<cr>
nnoremap <silent> <buffer> u :call buffers#actions#delete('bunload')<cr>
nnoremap <silent> <buffer> U :call buffers#actions#delete('bunload!')<cr>
