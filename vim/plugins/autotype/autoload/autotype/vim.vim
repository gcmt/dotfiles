
func! autotype#vim#space()
	let line = getline('.')
	let indent = indent(line('.'))
	if g:autotype_disabled || autotype#inside('String', 'Comment') || indent < indent(line('.')+1)
		return get(g:, 'loaded_pairs', 0) ? pairs#space() : ' '
	end
	if line =~ '\v^\s*if$' && getline(line('.')+1) !~ '\v^'.repeat('\s', indent).'else'
		return " \<cr>end\<esc>kA"
	end
	if line =~ '\v^\s*func?!?$'
		return " \<cr>endf\<esc>kA"
	end
	if line =~ '\v^\s*for$'
		return " \<cr>endfo\<esc>kA"
	end
	if line =~ '\v^\s*while$'
		return " \<cr>endw\<esc>kA"
	end
	return get(g:, 'loaded_pairs', 0) ? pairs#space() : ' '
endf
