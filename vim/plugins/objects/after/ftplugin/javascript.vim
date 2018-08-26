
vnoremap <silent> <buffer> af :<c-u>call objects#javascript#function(0, 0)<cr>
onoremap <silent> <buffer> af :<c-u>exec 'norm v'.v:count1.'af'<cr>
vnoremap <silent> <buffer> aF :<c-u>call objects#javascript#function(0, 1)<cr>
onoremap <silent> <buffer> aF :<c-u>exec 'norm v'.v:count1.'aF'<cr>
vnoremap <silent> <buffer> if :<c-u>call objects#javascript#function(1, 0)<cr>
onoremap <silent> <buffer> if :<c-u>exec 'norm v'.v:count1.'if'<cr>

vnoremap <silent> <buffer> ac :<c-u>call objects#javascript#class(0, 0)<cr>
onoremap <silent> <buffer> ac :<c-u>exec 'norm v'.v:count1.'ac'<cr>
vnoremap <silent> <buffer> aC :<c-u>call objects#javascript#class(0, 1)<cr>
onoremap <silent> <buffer> aC :<c-u>exec 'norm v'.v:count1.'aC'<cr>
vnoremap <silent> <buffer> ic :<c-u>call objects#javascript#class(1, 0)<cr>
onoremap <silent> <buffer> ic :<c-u>exec 'norm v'.v:count1.'ic'<cr>
