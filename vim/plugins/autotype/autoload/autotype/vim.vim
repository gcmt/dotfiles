

func! autotype#vim#space()
	let Space = {-> exists('*pairs#space') ? pairs#space() : ' '}

	let line = getline('.')
	let next = getline(nextnonblank(line('.')+1))
	let indent = autotype#indent(line)

	if g:autotype_disabled || autotype#inside('String', 'Comment') || indent < autotype#indent(next)
		return Space()
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

	return Space()
endf
