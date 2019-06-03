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

command! -bang -nargs=? Explorer call explorer#open(<q-args>, !empty(<q-bang>))

let s:options = {
	\ 'hidden_files': 1,
	\ 'filters': [],
	\ 'filters_active': 1,
	\ 'expand_depth': 3,
\ }

for [s:option, s:default] in items(s:options)
	let g:explorer_{s:option} = get(g:, 'explorer_'.s:option, s:default)
endfo

func s:setup_colors()
	hi default link ExplorerTitle Magenta
	hi default link ExplorerPipe Comment
	hi default link ExplorerDir Blue
	hi default link ExplorerLink Cyan
	hi default link ExplorerExec Green
	hi default link ExplorerDim Comment
endf

call s:setup_colors()

func s:edit_directory(path)
	bwipe
	call explorer#open(a:path)
endf

aug _explorer
	au BufWritePost .vimrc call <sid>setup_colors()
	au Colorscheme * call <sid>setup_colors()
	au VimEnter,BufReadPost * if isdirectory(expand('%:p')) | call <sid>edit_directory(expand('%:p')) | end
aug END
