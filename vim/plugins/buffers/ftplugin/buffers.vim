
nnoremap <silent> <buffer> q :close<cr>

nnoremap <silent> <buffer> <enter> :call buffers#actions#edit('edit')<cr>zz
nnoremap <silent> <buffer> <c-j> :call buffers#actions#edit('edit')<cr>zz
nnoremap <silent> <buffer> l :call buffers#actions#edit('edit')<cr>zz
nnoremap <silent> <buffer> e :call buffers#actions#edit('edit')<cr>zz
nnoremap <silent> <buffer> o :call buffers#actions#edit('edit')<cr>zz
nnoremap <silent> <buffer> t :call buffers#actions#edit('tabedit')<cr>zz
nnoremap <silent> <buffer> s :call buffers#actions#edit('split')<cr>zz
nnoremap <silent> <buffer> v :call buffers#actions#edit('vsplit')<cr>zz

nnoremap <silent> <buffer> dd :call buffers#actions#delete('bdelete')<cr>
nnoremap <silent> <buffer> DD :call buffers#actions#delete('bdelete!')<cr>
nnoremap <silent> <buffer> ww :call buffers#actions#delete('bwipe')<cr>
nnoremap <silent> <buffer> WW :call buffers#actions#delete('bwipe!')<cr>
nnoremap <silent> <buffer> uu :call buffers#actions#delete('bunload')<cr>
nnoremap <silent> <buffer> UU :call buffers#actions#delete('bunload!')<cr>
