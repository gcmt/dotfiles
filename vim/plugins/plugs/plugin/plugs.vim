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

let g:plugs_list = get(g:, 'plugs_list', [])
let g:plugs_dir = get(g:, 'plugs_dir', '')

comm! PlugsInstall call plugs#install()
