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

vnoremap <silent> aa :<c-u>call objects#items#func(0)<cr>
onoremap <silent> aa :<c-u>norm vaa<cr>
vnoremap <silent> ia :<c-u>call objects#items#func(1)<cr>
onoremap <silent> ia :<c-u>norm via<cr>

vnoremap <silent> ai :<c-u>call objects#items#list(0)<cr>
onoremap <silent> ai :<c-u>norm vai<cr>
vnoremap <silent> ii :<c-u>call objects#items#list(1)<cr>
onoremap <silent> ii :<c-u>norm vii<cr>

vnoremap <silent> ak :<c-u>call objects#items#dict(0)<cr>
onoremap <silent> ak :<c-u>norm vak<cr>
vnoremap <silent> ik :<c-u>call objects#items#dict(1)<cr>
onoremap <silent> ik :<c-u>norm vik<cr>
