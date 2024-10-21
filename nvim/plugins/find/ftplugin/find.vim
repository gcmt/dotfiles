
func! s:edit(cmd) abort
    let win = winnr()
    let path = get(b:find.table, line('.'), '')
    if !empty(path)
        wincmd p
        exec win.'wincmd c'
        let path = substitute(path, getcwd().'/', '', '')
        exec a:cmd fnameescape(path)
    end
endf

nnoremap <silent> <buffer> q :close<cr>
nnoremap <silent> <buffer> <enter> :call <sid>edit('edit')<cr>zz
nnoremap <silent> <buffer> <c-j> :call <sid>edit('edit')<cr>zz
nnoremap <silent> <buffer> l :call <sid>edit('edit')<cr>zz
nnoremap <silent> <buffer> o :call <sid>edit('edit')<cr>zz
nnoremap <silent> <buffer> e :call <sid>edit('edit')<cr>zz
nnoremap <silent> <buffer> t :call <sid>edit('tabedit')<cr>zz
nnoremap <silent> <buffer> s :call <sid>edit('split')<cr>zz
nnoremap <silent> <buffer> v :call <sid>edit('vsplit')<cr>zz
