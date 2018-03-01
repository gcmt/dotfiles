" ============================================================================
" File: explorer.vim
" Description: Minimal file explorer
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:explorer_loaded') || &cp
	finish
end
let g:explorer_loaded = 1

command! -nargs=? Explorer call explorer#open(<q-args>)

let s:options = {
	\ 'hidden_files': 1,
	\ 'hide_owner_and_group': 0,
\ }

for [s:option, s:default] in items(s:options)
	let g:explorer_{s:option} = get(g:, 'explorer_'.s:option, s:default)
endfo

func s:setup_colors()
	hi default link ExplorerDim Comment
	hi default link ExplorerDetails Special
	hi default link ExplorerDir Blue
	hi default link ExplorerLink Cyan
endf

call s:setup_colors()

aug _explorer
	au BufWritePost .vimrc call <sid>setup_colors()
	au Colorscheme * call <sid>setup_colors()
aug END
