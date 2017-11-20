" ============================================================================
" File: taglist.vim
" Description: Search tags
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if !executable('rg') || exists('g:taglist_loaded') || &cp
	finish
end
let g:taglist_loaded = 1

command! -bang -nargs=1 -complete=tag Tag call taglist#find(<q-bang>, <q-args>)

let s:options = {
	\ 'grepprg': 'rg -j 1 -N -H --no-heading --no-messages',
	\ 'max_winsize': 75,
	\ 'max_results': 100,
\ }

for [s:option, s:default] in items(s:options)
	let g:taglist_{s:option} = get(g:, 'taglist_'.s:option, s:default)
endfor

func s:setup_colors()
	hi default link TaglistTitle Statement
	hi default link TaglistMeta Special
	hi default link TaglistPath Comment
endf

call s:setup_colors()

aug _taglist
	au BufWritePost .vimrc call <sid>setup_colors()
	au Colorscheme * call <sid>setup_colors()
aug END
