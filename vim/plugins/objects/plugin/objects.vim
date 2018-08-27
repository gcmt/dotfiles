" =============================================================================
" File: objects.vim
" Description: Vim text objects enhanced
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================


let g:objects_enabled = get(g:, 'objects_enabled', 0)
let g:objects_options = get(g:, 'objects_options', {})


if objects#enabled('items#args')
	call objects#map('aa', 'objects#items#args')
	call objects#map('ia', 'objects#items#args', {'inner': 1})
end


if objects#enabled('items#list')
	call objects#map('ai', 'objects#items#list')
	call objects#map('ii', 'objects#items#list', {'inner': 1})
end


if objects#enabled('items#dict')
	call objects#map('ak', 'objects#items#dict')
	call objects#map('ik', 'objects#items#dict', {'inner': 1})
end
