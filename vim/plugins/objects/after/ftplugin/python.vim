
vnoremap <silent> <buffer> af :<c-u>call objects#python#function(0, 0)<cr>
onoremap <silent> <buffer> af :<c-u>norm vaf<cr>
vnoremap <silent> <buffer> if :<c-u>call objects#python#function(1, 0)<cr>
onoremap <silent> <buffer> if :<c-u>norm vif<cr>

vnoremap <silent> <buffer> aF :<c-u>call objects#python#function(0, 1)<cr>
onoremap <silent> <buffer> aF :<c-u>norm vaF<cr>
vnoremap <silent> <buffer> iF :<c-u>call objects#python#function(1, 1)<cr>
onoremap <silent> <buffer> iF :<c-u>norm viF<cr>

vnoremap <silent> <buffer> ac :<c-u>call objects#python#class(0, 0)<cr>
onoremap <silent> <buffer> ac :<c-u>norm vac<cr>
vnoremap <silent> <buffer> ic :<c-u>call objects#python#class(1, 0)<cr>
onoremap <silent> <buffer> ic :<c-u>norm vic<cr>

vnoremap <silent> <buffer> aC :<c-u>call objects#python#class(0, 1)<cr>
onoremap <silent> <buffer> aC :<c-u>norm vaC<cr>
vnoremap <silent> <buffer> iC :<c-u>call objects#python#class(1, 1)<cr>
onoremap <silent> <buffer> iC :<c-u>norm viC<cr>
