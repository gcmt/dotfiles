
vnoremap <silent> <buffer> af :<c-u>call objects#javascript#function(0)<cr>
onoremap <silent> <buffer> af :<c-u>exec 'norm v'.v:count1.'af'<cr>
vnoremap <silent> <buffer> if :<c-u>call objects#javascript#function(1)<cr>
onoremap <silent> <buffer> if :<c-u>exec 'norm v'.v:count1.'if'<cr>
