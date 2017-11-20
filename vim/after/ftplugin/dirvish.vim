
nmap <buffer> h -
nmap <buffer> l <cr>

let stl = ' ' . substitute(expand('%:p'), $HOME, '~', '')[:-2] . '%=dirvish '
call setwinvar(0, '&stl', stl)
