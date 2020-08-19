
func! flow#python#setup()
	inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=flow#python#esco()<cr>
endf

func! flow#python#esco()

	if g:flow_disabled || flow#inside('Comment')
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
