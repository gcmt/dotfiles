wincmd J

nnoremap <silent> <buffer> q <c-w>c

aug _help
     au!
     au BufWinEnter <buffer> exec "norm" "40\<c-w>_"
aug END
