
func! autotype#vim#space()
	let line = getline('.')
	let nextline = getline(nextnonblank(line('.')+1))
	let indent = matchstr(line, '\v^\s*')
	let nextindent = matchstr(nextline, '\v^\s*')
	if g:autotype_disabled || autotype#inside('String', 'Comment') || len(indent) < len(nextindent)
		return get(g:, 'loaded_pairs', 0) ? pairs#space() : ' '
	end
	if line =~ '\v^\s*if$' && nextline !~ '\v^'.indent.'(else|end%[if])>'
		return " \<cr>end\<esc>kA"
	end
	if line =~ '\v^\s*func?!?$' && nextline !~ '\v^'.indent.'endf%[untion]>'
		return " \<cr>endf\<esc>kA"
	end
	if line =~ '\v^\s*for$' && nextline !~ '\v^'.indent.'endfo%[r]>'
		return " \<cr>endfo\<esc>kA"
	end
	if line =~ '\v^\s*while$' && nextline !~ '\v^'.indent.'endw%[hile]>'
		return " \<cr>endw\<esc>kA"
	end
	return get(g:, 'loaded_pairs', 0) ? pairs#space() : ' '
endf
