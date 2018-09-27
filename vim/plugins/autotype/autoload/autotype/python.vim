
func! autotype#python#esc_o()

	if g:autotype_disabled || autotype#inside('Comment')
		return "\<esc>o"
	end

	let line = getline('.')

	let keywords = '(def|class|if|elif|else|for|while|try|except|with)'
	if line =~ '\v^\s*'.keywords.'>' && line !~ '\v:$'
		call setline(line('.'), substitute(line, '\v\s*$', ':', ''))
	end

	return "\<esc>o"
endf


func! autotype#python#colon()

	if g:autotype_disabled || autotype#inside('Comment', 'String')
		return ':'
	end

	let line = getline('.')

	if line =~ '\v^\s*try>'
		return ":\<cr>"
	end

	return ':'
endf
