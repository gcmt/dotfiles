" =============================================================================
" File: pairs.vim
" Description: Basic autoclose functionality
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

if exists("g:loaded_pairs") || &cp
	finish
end
let g:loaded_pairs = 1

inoremap <expr> { pairs#insert_paren('{')
inoremap <expr> [ pairs#insert_paren('[')
inoremap <expr> ( pairs#insert_paren('(')
inoremap <expr> " pairs#insert_quote('"')
inoremap <expr> ' pairs#insert_quote("'")
inoremap <expr> ` pairs#insert_quote("`")

inoremap <expr> <bs> pairs#delete("\<bs>")
inoremap <expr> <c-h> pairs#delete("\<bs>")
inoremap <expr> <c-w> pairs#delete("\<c-w>")

inoremap <expr> <space> pairs#space()

inoremap <expr> <c-j> pairs#newline()
inoremap <expr> <enter> pairs#newline()
