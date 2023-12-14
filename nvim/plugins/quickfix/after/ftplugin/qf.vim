
setl nonumber
setl norelativenumber
setl cursorline

fun! _quickfix_title()
    let title = get(w:, 'quickfix_title', '')
    let title = substitute(title, &grepprg, get(split(&grepprg), 0, '') . ' ', '')
    return substitute(title, $HOME, '~', 'g')
endf

setl stl=%t\ %{_quickfix_title()}

func! s:set_height(percentage)
    exec 'resize' float2nr(&lines * a:percentage / 100)
    if line('$') <= winheight(0)
        exec 'resize' line('$')
    end
endf

call s:set_height(get(g:, 'quickfix_height', 25))

norm! zz

nnoremap <buffer> q <c-w>c

" don't close the quickfix window
nnoremap <silent> <buffer> L <enter>zz
nnoremap <silent> <buffer> l <enter>:exec winnr('#').'wincmd c'<cr>zz

vnoremap <silent> <buffer> d :call quickfix#remove_entries(mode())<cr>
nnoremap <silent> <buffer> d :<c-u>set opfunc=quickfix#remove_entries<cr>g@
nnoremap <silent> <buffer> dd :<c-u>set opfunc=quickfix#remove_entries<bar>exec 'norm!' v:count1.'g@_'<cr>
nnoremap <silent> <buffer> u :<c-u>call quickfix#undo()<cr>

command! -buffer -bang -nargs=1 Cfilter call quickfix#filter(<q-bang>, <q-args>)
command! -buffer -bang -nargs=1 Cffilter call quickfix#ffilter(<q-bang>, <q-args>)
