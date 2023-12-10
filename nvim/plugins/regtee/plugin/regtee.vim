" ============================================================================
" File: regtee.vim
" Description: Copy yanked text to a sticky register
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:regtee_loaded') || !exists("##TextYankPost") || &cp
    finish
end
let g:regtee_loaded = 1

let g:regtee_register = ""

command! -nargs=? Regtee call regtee#regtee(<q-args>)
