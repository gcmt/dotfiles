" =============================================================================
" File: quickfix.vim
" Description: Quickfix enhancements
" Author: github.com/gcmt
" License: MIT
" =============================================================================

" quickfix#remove_entries({type:string}) -> 0
" Remove entries from the quickfix list.
func quickfix#remove_entries(type) abort range
	if empty(getqflist())
		return
	end
	if a:type == 'line'
		let [start, end] = [line("'["), line("']")]
	elseif a:type ==# 'V' || a:type == 'n'
		let [start, end] = [a:firstline, a:lastline]
	else
		return
	end
	let view = winsaveview()
	let qf = getqflist()
	let title = s:getqftitle()
	let context = s:getqfcontext()
	let context.snapshots = get(context, 'snapshots', []) + [copy(qf)]
	call remove(qf, start - 1, end - 1)
	call setqflist(qf, 'r')
	call setqflist([], 'a', {'context': context, 'title': title})
	call winrestview(view)
	doau User QuickFixEditPost
endf

" quickfix#undo() -> 0
" Undo the last v:count1 deletions.
func quickfix#undo()
	let title = s:getqftitle()
	let context = s:getqfcontext()
	let snapshots = get(context, 'snapshots', [])
	if empty(snapshots)
		return
	end
	let view = winsaveview()
	let snapshot = []
	let deletions = min([v:count1, len(snapshots)])
	for i in range(deletions)
		let snapshot = remove(context.snapshots, -1)
	endfo
	call setqflist(snapshot, 'r')
	call setqflist([], 'a', {'context': context, 'title': title})
	call winrestview(view)
	doau User QuickFixEditPost
endf

" s:getqfcontext() -> dict
" Get the quickfix context.
" If the context value is not a dictionary, an empty dictionary is returned.
func s:getqfcontext()
	let ctx = getqflist({'context': 1}).context
	return type(ctx) == v:t_dict ? ctx : {}
endf

" s:getqftitle() -> string
" Get the quickfix title.
func s:getqftitle()
	return getqflist({'title': 1}).title
endf
