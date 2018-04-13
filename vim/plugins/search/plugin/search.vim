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
	if empty(a:bang)
		call search#do(bufnr('%'), a:pattern, '__search__', {}, {})
	else
		let search_options = {'exclude_syn': ['Comment', 'String']}
		call search#do(bufnr('%'), a:pattern, '__search__', search_options, {})
	end
endf
