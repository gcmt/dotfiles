
func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf

func! s:pathjoin(a, b)
	return a:a . (a:a =~ '\v/$' ? '' : '/') . substitute(a:b, '\v(^/+|/+$)', '', 'g')
endf

func! plugs#actions#install() abort
	let entry = get(b:plugs.table, line('.'), {})
	if empty(entry)
		return
	end
	if empty(entry.url)
		return s:err("Plugin not listed")
	end
	let dest = s:pathjoin(g:plugs_path, entry.name)
	if isdirectory(dest)
		return s:err("Plugin already installed")
	end
	echo "Installing" entry.url . "..."
	let out = system(printf('git clone %s %s', shellescape(entry.url), shellescape(dest)))
	if v:shell_error
		return s:err(out)
	end
	call plugs#render()
endf

func! plugs#actions#install_all() abort
	for entry in values(b:plugs.table)
		let dest = s:pathjoin(g:plugs_path, entry.name)
		if isdirectory(dest) || empty(entry.url)
			continue
		end
		echo "Installing" entry.url . "..."
		let out = system(printf('git clone %s %s', shellescape(entry.url), shellescape(dest)))
		if v:shell_error
			call s:err(out)
		end
	endfo
	call plugs#render()
endf

func! plugs#actions#update() abort
	let entry = get(b:plugs.table, line('.'), {})
	if empty(entry)
		return
	end
	let dest = s:pathjoin(g:plugs_path, entry.name)
	if !isdirectory(dest)
		return s:err("Plugin not installed")
	end
	echo "Updating" entry.url . "..."
	let out = system(printf('git -C %s pull', shellescape(dest)))
	if v:shell_error
		return s:err(out)
	else
		echo out
	end
	call plugs#render()
endf

func! plugs#actions#update_all() abort
	for entry in values(b:plugs.table)
		let dest = s:pathjoin(g:plugs_path, entry.name)
		if !isdirectory(dest)
			return s:err("Plugin not installed")
		end
		echo "Updating" entry.url . "..."
		let out = system(printf('git -C %s pull', shellescape(dest)))
		if v:shell_error
			call s:err(out)
		else
			echo out
		end
	endfo
	call plugs#render()
endf

func! plugs#actions#delete() abort
	let entry = get(b:plugs.table, line('.'), {})
	if empty(entry)
		return
	end
	let dest = s:pathjoin(g:plugs_path, entry.name)
	if !isdirectory(dest)
		return s:err("plugin not intalled")
	end
	echo printf("Removing %s... are you sure? [Yn] ", fnamemodify(dest, ':~'))
	if nr2char(getchar()) =~ "\\v^(y|\<cr>)$"
		call delete(dest, 'rf')
	end
	call plugs#render()
	redraw | echo
endf
