" =============================================================================
" File: taggify.vim
" Description: Quick html tag creation (streamlined version of emmet-vim)
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

" Usage:
"
"   - div => <div|></div>
"   - div.container => <div class="container"|></div>
"   - h1.main.header => <h1 class="main header"|></h1>
"   - div#wrapper => <div id="wrapper"|></div>
"   - h1.header#title => <h1 id="title" class="header"|></h1>
"

if exists("g:loaded_taggify") || &cp
    finish
endif

let g:loaded_taggify = 1

inoremap <silent> <plug>(taggify) <c-r>=<sid>expand(0)<cr>
inoremap <silent> <plug>(taggify-inline) <c-r>=<sid>expand(1)<cr>

func s:expand(inline)
	if strpart(getline('.'), col('.') - 1) =~ '\v^\>'
		return "\<esc>la"
	end
	return taggify#expand(a:inline)
endf
