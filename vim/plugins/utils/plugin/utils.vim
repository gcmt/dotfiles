" ============================================================================
" File: utils.vim
" Description: Various utilities
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:utils_loaded') || &cp
	finish
end
let g:utils_loaded = 1

" resize windows using percentages
command! -nargs=+ Res call utils#resize_window(<q-args>)

" rename the current buffer
command! -bang -nargs=1 Rename call utils#rename_buffer(<q-bang>, <q-args>)

" save the current buffer as sudo
command! -nargs=0 Sudow exec 'write !sudo tee % > /dev/null'

" cd into the project root
command! -bang -nargs=0 CdRoot call utils#cd_into_root(<q-bang>)

" clear undo history
command! -nargs=0 ClearUndo call utils#clear_undo()

" execute zz when jumping offscreen and show cursorline
command! -bang -nargs=1 Zz call utils#zz(<q-bang>, <q-args>)

" toggle zooming
command! -nargs=0 Zoom call utils#zoom_toggle()

" execute commands silently and redraw
command! -nargs=+ Sil exec 'sil!' <q-args> | redraw!
