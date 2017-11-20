
set number

iabbrev <buffer> DIR __DIR__
iabbrev <buffer> POST $_POST
iabbrev <buffer> GET $_GET

nnoremap <buffer> <f5> :!php %<cr>
inoremap <buffer> <f5> <esc>:!php %<cr>

nnoremap <silent> <buffer> <leader>c :Search ^\s*(class\b\\|((static\s)?(public\s\\|private\s\\|protected\s)?function\b))<cr>

" reset html mappings
inoremap <buffer> <cr> <cr>
imap <buffer> <c-j> <cr>
inoremap <buffer> <tab> <tab>
vnoremap <buffer> <tab> <tab>
inoremap <buffer> ! !

inoremap <buffer> <expr> ? getline('.') =~ '\v^$' && col('.') == 1 ? "<?php\<cr>" : '?'
