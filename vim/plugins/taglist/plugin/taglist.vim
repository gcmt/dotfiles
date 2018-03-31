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

command! -bang -nargs=1 -complete=tag Tag call taglist#open(<q-bang>, <q-args>)

let s:options = {
	\ 'grepprg': 'rg -j 1 -N -H --no-heading --no-messages',
	\ 'visible_tagfiles': 0,
	\ 'max_winsize': 75,
	\ 'max_results': 100,
\ }

for [s:option, s:default] in items(s:options)
	let g:taglist_{s:option} = get(g:, 'taglist_'.s:option, s:default)
endfor

func s:setup_colors()
	hi default link TaglistTagfile Magenta
	hi default link TaglistFile Blue
	hi default link TaglistLineNr LineNr
	hi default link TaglistTagname Normal
	hi default link TaglistMeta Special
	hi default link TaglistLink Special
endf

call s:setup_colors()

aug _taglist
	au BufWritePost .vimrc call <sid>setup_colors()
	au Colorscheme * call <sid>setup_colors()
aug END
