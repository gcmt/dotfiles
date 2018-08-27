" =============================================================================
" File: objects.vim
" Description: Vim text objects enhanced
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

let g:objects_enabled = get(g:, 'objects_enabled', 0)
let g:objects_options = get(g:, 'objects_options', {})


if objects#enabled('items#args')
	call objects#map('aa', 'objects#items#args', 0)
	call objects#map('ia', 'objects#items#args', 1)
end

if objects#enabled('items#list')
	call objects#map('ai', 'objects#items#list', 0)
	call objects#map('ii', 'objects#items#list', 1)
end

if objects#enabled('items#dict')
	call objects#map('ak', 'objects#items#dict', 0)
	call objects#map('ik', 'objects#items#dict', 1)
end
