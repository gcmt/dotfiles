
func! autotype#python#setup()
	inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=autotype#python#esc_o()<cr>
	inoremap <silent> <buffer> : <c-]><c-g>u<c-r>=autotype#python#colon()<cr>
endf

func! autotype#python#esc_o()

	if g:autotype_disabled || autotype#inside('Comment')
		return "\<esc>o"
	end

	let line = getline('.')

	let keywords = '(async|def|class|if|elif|else|for|while|try|except|with)'
	if line =~ '\v^\s*'.keywords.'>' && line !~ '\v:$'
		if line =~ '\vwhile$'
			let line .= " True"
		end
		let line = substitute(line, '\v\s*$', ':', '')
		call setline(line('.'), line)
	end

	return "\<esc>o"
endf

func! autotype#python#colon()

	if g:autotype_disabled || autotype#inside('Comment', 'String')
		return ':'
	end

	return ':'
endf
