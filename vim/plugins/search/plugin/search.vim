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

func s:search(bang, pattern)
	let bufname = '__search__'
	if bufwinnr(bufname) != -1
		exec bufwinnr(bufname) . 'wincmd c'
	end
	let options = empty(a:bang) ? {} : {'exclude_syn': ['Comment', 'String']}
	call search#do(bufnr('%'), a:pattern, bufname, options, {})
endf

command -bang -nargs=? Search call <sid>search(<q-bang>, <q-args>)

func s:setup_colors()
	hi default link SearchMatch RedBold
endf

call s:setup_colors()

aug _spotter
	au Colorscheme * call <sid>setup_colors()
aug END
