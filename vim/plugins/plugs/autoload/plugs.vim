
func! s:err(msg)
	echohl ErrorMsg | echo 'Plugs:' a:msg | echohl None
endf

func! plugs#install() abort
	if empty(g:plugs_dir) || !isdirectory(g:plugs_dir)
		return s:err("'g:plugs_dir' must be a valid directory")
	end
	let list = map(copy(g:plugs_list), "[v:val, g:plugs_dir.'/'.split(v:val,'/')[-1]]")
	for [url, dest] in filter(list, "!isdirectory(v:val[1])")
		echo "Installing" url . "..."
		let out = system(printf('git clone %s %s', shellescape(url), shellescape(dest)))
		if v:shell_error
			echo out
		end
	endfo
	doau User UpdateRtp
endf
