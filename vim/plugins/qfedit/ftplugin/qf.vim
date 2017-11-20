
vnoremap <silent> <buffer> d :call qfedit#remove_entries(mode())<cr>
nnoremap <silent> <buffer> d :<c-u>set opfunc=qfedit#remove_entries<cr>g@
nnoremap <silent> <buffer> dd :<c-u>set opfunc=qfedit#remove_entries<bar>exec 'norm!' v:count1.'g@_'<cr>
nnoremap <silent> <buffer> u :call qfedit#undo(1)<cr>
nnoremap <silent> <buffer> U :call qfedit#undo(-1)<cr>
