" =============================================================================
" File: autoload/qfedit.vim
" Description: Quickfix editing for a more effective :cdo command
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

let s:history = []

aug _qfedit
	au!
	au QuickFixCmdPre * let s:history = []
aug END

func s:remove_entries(start, end)
	let view_save = winsaveview()
	let title_save = w:quickfix_title
	let quickfix = getqflist()
	let removed = remove(quickfix, a:start - 1, a:end - 1)
	call add(s:history, [a:start - 1, removed])
	call setqflist(quickfix, 'r')
	call setqflist([], 'a', {'title': title_save})
	call winrestview(view_save)
	doau User QfEditPostEdit
endf

" Remove entries from the quickfix list.
func qfedit#remove_entries(type) abort range
	if empty(getqflist())
		return
	end
	if a:type == 'line'
		call s:remove_entries(line("'["), line("']"))
	elseif a:type ==# 'V' || a:type == 'n'
		call s:remove_entries(a:firstline, a:lastline)
	end
endf

" Undo the last N deletions. When N == -1 everything gets undoed.
func qfedit#undo(n)
	if empty(s:history)
		return
	end
	let n = a:n < 0 ? len(s:history) : a:n
	let pos = line('.')
	let quickfix = getqflist()
	let title_save = w:quickfix_title
	while !empty(s:history) && n > 0
		let [pos, entries] = remove(s:history, -1)
		while !empty(entries)
			let quickfix = insert(quickfix, remove(entries, 0), pos)
			let pos += 1
		endw
		let n -= 1
	endwhile
	call setqflist(quickfix, 'r')
	call setqflist([], 'a', {'title': title_save})
	exec pos
	doau User QfEditPostEdit
endf
