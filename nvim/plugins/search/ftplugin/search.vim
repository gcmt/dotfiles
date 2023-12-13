
nnoremap <silent> <buffer> q :close<cr>
nnoremap <silent> <buffer> <esc> :close<cr>

nnoremap <silent> <buffer> l :call <sid>jump()<cr>
nnoremap <silent> <buffer> <cr> :call <sid>jump()<cr>
nnoremap <silent> <buffer> <c-j> :call <sid>jump()<cr>

func! s:jump()
    let bufnr = b:search.s.curr_bufnr
    let entry = get(b:search.table, line('.'), [])
    if empty(entry)
        return
    end
    close
    norm! m'
    exec bufnr 'buffer'
    call cursor(entry)
    norm! zz
endf

nnoremap <silent> <buffer> c :<c-u>call <sid>show_context()<cr>

func! s:show_context()
    let bufnr = b:search.s.curr_bufnr
    let entry = get(b:search.table, line('.'), [])
    if empty(entry)
        return
    end
    let start = max([entry[0] - v:count1, 1])
    let end = entry[0] + v:count1
    echo join(getbufline(bufnr, start, end), "\n")
endf

