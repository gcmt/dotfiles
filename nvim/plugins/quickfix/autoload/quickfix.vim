" =============================================================================
" File: quickfix.vim
" Description: Quickfix enhancements
" Author: github.com/gcmt
" License: MIT
" =============================================================================

" quickfix#remove_entries({type:string}) -> 0
" Remove entries from the quickfix list.
func quickfix#remove_entries(type) abort range
    let start = a:type == 'line' ? line("'[") : a:firstline
    let end = a:type == 'line' ? line("']") : a:lastline
    let qf = getqflist({'all': 1})
    if empty(qf.items)
        return
    end
    let view = winsaveview()
    call s:snapshot(qf)
    call remove(qf.items, start - 1, end - 1)
    call setqflist([], 'r', qf)
    call winrestview(view)
    doau User QuickFixEditPost
endf

" quickfix#undo() -> 0
" Undo the last v:count1 deletions.
func quickfix#undo()
    let qf = getqflist({'all': 1})
    if type(qf.context) != v:t_dict || !has_key(qf.context, 'snapshots')
        return
    end
    let snapshots = qf.context.snapshots
    if empty(snapshots)
        return
    end
    let view = winsaveview()
    let qf.items = []
    for i in range(min([v:count1, len(snapshots)]))
        let qf.items = remove(snapshots, -1)
    endfo
    call setqflist([], 'r', qf)
    call winrestview(view)
    doau User QuickFixEditPost
endf

" quickfix#filter({bang:string}, {pattern:string}) -> 0
" Filter quickfix entries by the text attribute. Unless a {bang} is used, keep
" only quickfix entries for which the 'text' attribute contains {pattern}. If
" a {bang} is used, those entries are removed instead.
func quickfix#filter(bang, pattern)
    call s:qfilter(a:pattern, {->v:val['text']}, a:bang == '!')
endf

" quickfix#ffilter({bang:string}, {pattern:string}) -> 0
" Same as quickfix#filter but filter by matching against file names.
func quickfix#ffilter(bang, pattern)
    call s:qfilter(a:pattern, {-> fnamemodify(bufname(v:val['bufnr']), ':p')}, a:bang == '!')
endf

" s:qfilter({pattern:string}, {val:funcref}[, {inverse:number}]) -> 0
" Filter quickfix entries. Unless {inverse} is given and it's 1, keep only
" quickfix entries for which the value returned by the {val} function contains
" {pattern}. If {inverse} is given and it's 1, those entries are removed instead.
func! s:qfilter(pattern, val, inverse)
    let qf = getqflist({'all': 1})
    call s:snapshot(qf)
    let Match = a:inverse ? {v, p -> v !~ p} : {v, p -> v =~ p}
    call filter(qf.items, {i, entry -> Match(a:val(entry), a:pattern)})
    if qf.size != len(qf.items)
        call setqflist([], 'r', qf)
        doau User QuickFixEditPost
    end
endf

" s:snapshot({qf:dict}) -> 0
" Create a snapshot of the given quickfix by storing a copy of all items
" in the quickfix context.
" {qf} is expected to be the value returned by getqflist({'all': 1})
func s:snapshot(qf)
    if type(a:qf.context) != v:t_dict
        let a:qf.context = {}
    end
    let a:qf.context.snapshots = get(a:qf.context, 'snapshots', []) + [copy(a:qf.items)]
endf
