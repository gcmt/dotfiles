" =============================================================================
" File: plugs.vim
" Description: Easier management of external plugins
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

if exists("g:loaded_plugs") || &cp
	finish
end
let g:loaded_plugs = 1

comm! Plugs call plugs#show()

let s:options = {
	\ 'path': '',
	\ 'list': [],
	\ 'max_winsize': 50,
	\ 'min_winsize': 1,
\ }

for [s:option, s:default] in items(s:options)
	let g:plugs_{s:option} = get(g:, 'plugs_'.s:option, s:default)
endfor

func s:setup_colors()
	hi default link PlugsDim Comment
	hi default link PlugsOrphan Red
	hi default link PlugsInstalled Normal
	hi default link PlugsNotInstalled FgDim
endf

call s:setup_colors()

aug _plugs
	au BufWritePost .vimrc call <sid>setup_colors()
	au Colorscheme * call <sid>setup_colors()
aug END
