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
	\ 'directories_first': 1,
	\ 'auto_hide_owner_and_group': 80,
	\ 'hide_owner_and_group': 0,
	\ 'details_color': 'ExplorerDetails',
	\ 'dirs_color': 'ExplorerDirs',
	\ 'links_color': 'ExplorerLinks',
	\ 'execs_color': 'ExplorerExecs',
\ }

for [s:option, s:default] in items(s:options)
	let g:explorer_{s:option} = get(g:, 'explorer_'.s:option, s:default)
endfo

func s:setup_colors()
	hi default link ExplorerDetails Special
	hi default link ExplorerDirs Blue
	hi default link ExplorerLinks Cyan
	hi default link ExplorerExecs Green
endf

call s:setup_colors()

aug _explorer
	au BufWritePost .vimrc call <sid>setup_colors()
	au Colorscheme * call <sid>setup_colors()
aug END
