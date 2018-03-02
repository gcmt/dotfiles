
vnoremap <silent> af :<c-u>call objects#python#function(0, 0)<cr>
onoremap <silent> af :<c-u>norm vaf<cr>
vnoremap <silent> if :<c-u>call objects#python#function(1, 0)<cr>
onoremap <silent> if :<c-u>norm vif<cr>

vnoremap <silent> aF :<c-u>call objects#python#function(0, 1)<cr>
onoremap <silent> aF :<c-u>norm vaF<cr>
vnoremap <silent> iF :<c-u>call objects#python#function(1, 1)<cr>
onoremap <silent> iF :<c-u>norm viF<cr>

vnoremap <silent> ac :<c-u>call objects#python#class(0, 0)<cr>
onoremap <silent> ac :<c-u>norm vac<cr>
vnoremap <silent> ic :<c-u>call objects#python#class(1, 0)<cr>
onoremap <silent> ic :<c-u>norm vic<cr>

vnoremap <silent> aC :<c-u>call objects#python#class(0, 1)<cr>
onoremap <silent> aC :<c-u>norm vaC<cr>
vnoremap <silent> iC :<c-u>call objects#python#class(1, 1)<cr>
onoremap <silent> iC :<c-u>norm viC<cr>
