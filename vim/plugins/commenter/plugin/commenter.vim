" =============================================================================
" File: commenter.vim
" Description: Comments operator
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

if exists("g:loaded_commenter") || &cp
    finish
end
let g:loaded_commenter = 1

vnoremap <silent> gc :call commenter#do(mode())<cr>
nnoremap <silent> gc :<c-u>set opfunc=commenter#do<cr>g@
nnoremap <silent> gcc :<c-u>set opfunc=commenter#do<bar>exec 'norm!' v:count1.'g@_'<cr>

command! -nargs=0 -range Commenter <line1>,<line2>call commenter#do(mode())
