
func! flow#vim#setup()
	inoremap <silent> <buffer> <space> <c-]><c-r>=flow#vim#space()<cr>
	inoremap <silent> <buffer> <c-t> <c-]><c-r>=flow#common#skipto('\v(end%[if]\|endf%[untion]\|endfo%[r]\|endw%[hile])', 1)<cr>
endf

func! flow#vim#space()

	let line = getline('.')
	let next = getline(nextnonblank(line('.')+1))
	let indent = flow#indent(line)

	if g:flow_disabled || flow#inside('String', 'Comment') || indent < flow#indent(next)
		return flow#common#space()
	end

	if line =~ '\v^\s*if$' && next !~ '\v^\s{'.indent.'}(else|end%[if])>'
		return " \<cr>end\<esc>kA"
	end

	if line =~ '\v^\s*fu%[nction]!?$' && next !~ '\v^\s{'.indent.'}endf%[untion]>'
		return " \<cr>endf\<esc>kA"
	end

	if line =~ '\v^\s*for$' && next !~ '\v^\s{'.indent.'}endfo%[r]>'
		return " \<cr>endfo\<esc>kA"
	end

	if line =~ '\v^\s*while$' && next !~ '\v^\s{'.indent.'}endw%[hile]>'
		return " \<cr>endw\<esc>kA"
	end

	return flow#common#space()
endf
