" ============================================================================
" File: search.vim
" Description: View all search matches at once
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:search_loaded') || &cp
	finish
end
let g:search_loaded = 1

command! -bang -nargs=? Search call <sid>search(<q-bang>, <q-args>)

func! s:search(bang, pattern)
	let bufname = '__search__'
	if bufwinnr(bufname) != -1
		exec bufwinnr(bufname) . 'wincmd c'
	end
	if empty(a:bang)
		call search#do(bufnr('%'), a:pattern, bufname, {}, {})
	else
		let search_options = {'exclude_syn': ['Comment', 'String']}
		call search#do(bufnr('%'), a:pattern, bufname, search_options, {})
	end
endf
