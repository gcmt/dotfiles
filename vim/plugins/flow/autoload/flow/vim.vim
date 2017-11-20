
fun! flow#vim#space()
	let line = getline('.')
	let indent = flow#indent('.')
	if g:flow_disabled || flow#inside('String', 'Comment') || indent < flow#indent(line('.')+1)
		return exists('g:loaded_pairs') ? pairs#space() : ' '
	end
	if line =~ '\v^\s*if$' && getline(line('.')+1) !~ '\v^'.repeat('\s', indent).'else'
		return " \<cr>end\<esc>kA"
	end
	if line =~ '\v^\s*fun!?$'
		return " \<cr>endf\<esc>kA"
	end
	if line =~ '\v^\s*for$'
		return " \<cr>endfo\<esc>kA"
	end
	if line =~ '\v^\s*while$'
		return " \<cr>endw\<esc>kA"
	end
	return exists('g:loaded_pairs') ? pairs#space() : ' '
endf
