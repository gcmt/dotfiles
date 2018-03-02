
vnoremap <silent> af :<c-u>call objects#python#function(0)<cr>
onoremap <silent> af :<c-u>norm vaf<cr>
vnoremap <silent> if :<c-u>call objects#python#function(1)<cr>
onoremap <silent> if :<c-u>norm vif<cr>

vnoremap <silent> ac :<c-u>call objects#python#class(0)<cr>
onoremap <silent> ac :<c-u>norm vac<cr>
vnoremap <silent> ic :<c-u>call objects#python#class(1)<cr>
onoremap <silent> ic :<c-u>norm vic<cr>
