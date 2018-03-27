" =============================================================================
" File: objects.vim
" Description: Vim text objects enhanced
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

vnoremap <silent> aa :<c-u>call objects#items#args(0)<cr>
onoremap <silent> aa :<c-u>exec 'norm v'.v:count1.'aa'<cr>
vnoremap <silent> ia :<c-u>call objects#items#args(1)<cr>
onoremap <silent> ia :<c-u>exec 'norm v'.v:count1.'ia'<cr>

vnoremap <silent> ai :<c-u>call objects#items#list(0)<cr>
onoremap <silent> ai :<c-u>exec 'norm v'.v:count1.'ai'<cr>
vnoremap <silent> ii :<c-u>call objects#items#list(1)<cr>
onoremap <silent> ii :<c-u>exec 'norm v'.v:count1.'ii'<cr>

vnoremap <silent> ak :<c-u>call objects#items#dict(0)<cr>
onoremap <silent> ak :<c-u>exec 'norm v'.v:count1.'ak'<cr>
vnoremap <silent> ik :<c-u>call objects#items#dict(1)<cr>
onoremap <silent> ik :<c-u>exec 'norm v'.v:count1.'ik'<cr>
