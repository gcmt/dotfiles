
aug _netrw
	au!
	" hidden apparently remains unset after leaving the netrw buffer
	au BufLeave <buffer> set hidden
aug END

setl nolist

" for some reasons the default mapping is: nmap <buffer> - <Plug>NetrwBrowseUpDir<Space>
nmap <buffer> - <plug>NetrwBrowseUpDir
nmap <buffer> h -
nmap <buffer> l <cr>
nmap <buffer> o <cr>
nmap <buffer> O o

" let stl = ' %{_alternate_buffer()}' . substitute(expand('%:p'), $HOME, '~', '')[:-2] . '%=netrw '
let stl = ' ' . substitute(expand('%:p'), $HOME, '~', '')[:-2] . '%=netrw '
call setwinvar(0, '&stl', stl)

if bufname('%') =~ 'NetrwTreeListing'
	call setwinvar(0, '&stl', ' netrw')
end
