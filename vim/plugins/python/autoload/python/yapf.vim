
func python#yapf#format() range
	let pos_save = getcurpos()
	let range = a:firstline != a:lastline ? a:firstline.'-'.a:lastline : 1.'-'.line('$')
	let file = shellescape(expand('%:p'))
	let out = system(printf('yapf --lines=%s %s', range, file))
	if v:shell_error
		return s:err("Yapf: An error occurred")
	end
	sil %delete _
	call setline(1, split(out, '\n'))
	call setpos('.', pos_save)
	sil! ALELint
endf

func s:err(msg)
	echohl WarningMsg | echom a:msg | echohl None
endf
