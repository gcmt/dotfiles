
func! flow#sh#setup()
	inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=flow#sh#space()<cr>
	inoremap <silent> <buffer> ( <c-]><c-g>u<c-r>=flow#sh#paren()<cr>
endf

func! flow#sh#paren()

	if g:flow_disabled || flow#inside('String', 'Comment')
		return flow#common#paren()
	end

	let line = getline('.')
	let next = getline(nextnonblank(line('.')+1))
	let indent = flow#indent('.')
	let next_indented = indent < flow#indent(next)

	if line =~ '\v\c^\s*[a-z0-9:_-]+$'
		let seq = "() {\<esc>F)i"
		if next !~ '\v^\s{'.indent.'}\}$' && !next_indented
			return seq . "\<esc>o}\<esc>O"
		end
		return seq
	end

	return flow#common#paren()
endf


func! flow#sh#space()

	if g:flow_disabled || flow#inside('String', 'Comment')
		return flow#common#space()
	end

	let line = getline('.')
	let next = getline(nextnonblank(line('.')+1))
	let indent = flow#indent(line)
	let next_indented = indent < flow#indent(next)

	if line =~ '\v^\s*elif$'
		return " ; then\<esc>F;i"
	end

	if line =~ '\v^\s*if$'
		let seq = " ; then\<esc>F;i"
		if next !~ '\v^\s{'.indent.'}(fi|else|elif)$' && !next_indented
			return seq . "\<esc>ofi\<esc>==k$F;i"
		end
		return seq
	end

	if line =~ '\v^\s*case$'
		let seq = "  in\<esc>bhi"
		if next !~ '\v^\s{'.indent.'}esac$' && !next_indented
			return seq."\<esc>oesac\<esc>k$bhi"
		end
		return seq
	end

	if line =~ '\v^\s*(while|for)$'
		let seq = " ; do\<esc>F;i"
		if next !~ '\v^\s{'.indent.'}done$' && !next_indented
			return seq."\<esc>odone\<esc>k$F;i"
		end
		return seq
	end

	return flow#common#space()
endf
