" =============================================================================
" File: objects.vim
" Description: Vim text objects enhanced
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

if exists("g:loaded_objects") || &cp
	finish
end
let g:loaded_objects = 1

vnoremap <silent> aa :<c-u>call objects#argument#select(0)<cr>
onoremap <silent> aa :<c-u>norm vaa<cr>
vnoremap <silent> ia :<c-u>call objects#argument#select(1)<cr>
onoremap <silent> ia :<c-u>norm via<cr>
