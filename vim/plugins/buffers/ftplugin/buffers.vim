
func! s:ctx(action)
	return extend(b:buffers, #{
		\ action: a:action,
		\ selected: line('.'),
	\ })
endf

nnoremap <silent> <buffer> q :close<cr>

nnoremap <silent> <buffer> a :call buffers#toggle_unlisted(<sid>ctx('toggle_unlisted'))<cr>

nnoremap <silent> <buffer> <enter> :call buffers#edit(<sid>ctx('edit'))<cr>
nnoremap <silent> <buffer> <c-j> :call buffers#edit(<sid>ctx('edit'))<cr>
nnoremap <silent> <buffer> l :call buffers#edit(<sid>ctx('edit'))<cr>
nnoremap <silent> <buffer> t :call buffers#edit(<sid>ctx('tab'))<cr>
nnoremap <silent> <buffer> s :call buffers#edit(<sid>ctx('split'))<cr>
nnoremap <silent> <buffer> v :call buffers#edit(<sid>ctx('vsplit'))<cr>

nnoremap <silent> <buffer> d :call buffers#delete(<sid>ctx('bdelete'))<cr>
nnoremap <silent> <buffer> D :call buffers#delete(<sid>ctx('bdelete!'))<cr>
nnoremap <silent> <buffer> w :call buffers#delete(<sid>ctx('bwipe'))<cr>
nnoremap <silent> <buffer> W :call buffers#delete(<sid>ctx('bwipe!'))<cr>
nnoremap <silent> <buffer> u :call buffers#delete(<sid>ctx('bunload'))<cr>
nnoremap <silent> <buffer> U :call buffers#delete(<sid>ctx('bunload!'))<cr>
