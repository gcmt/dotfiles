
vnoremap <silent> <buffer> af :<c-u>call objects#python#function(0)<cr>
onoremap <silent> <buffer> af :<c-u>exec 'norm v'.v:count1.'af'<cr>
vnoremap <silent> <buffer> if :<c-u>call objects#python#function(1)<cr>
onoremap <silent> <buffer> if :<c-u>exec 'norm v'.v:count1.'if'<cr>

vnoremap <silent> <buffer> ac :<c-u>call objects#python#class(0)<cr>
onoremap <silent> <buffer> ac :<c-u>exec 'norm v'.v:count1.'ac'<cr>
vnoremap <silent> <buffer> ic :<c-u>call objects#python#class(1)<cr>
onoremap <silent> <buffer> ic :<c-u>exec 'norm v'.v:count1.'ic'<cr>
