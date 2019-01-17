
func! autotype#sh#setup()
	inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=autotype#sh#space()<cr>
	inoremap <silent> <buffer> ( <c-]><c-g>u<c-r>=autotype#sh#outward_parenthesis()<cr>
endf

func! autotype#sh#outward_parenthesis()
	let Paren = {-> exists('*pairs#insert_paren') ? pairs#insert_paren('(') : '('}

	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return Paren()
	end

	let line = getline('.')
	let next = getline(nextnonblank(line('.')+1))
	let indent = autotype#indent('.')
	let next_indented = indent < autotype#indent(next)

	if line =~ '\v\c^\s*[a-z0-9:_-]+$'
		let seq = "() {\<esc>F)i"
		if next !~ '\v^\s{'.indent.'}\}$' && !next_indented
			return seq . "\<esc>o}\<esc>O"
		end
		return seq
	end

	return Paren()
endf


func! autotype#sh#space()
	let Space = {-> exists('*pairs#space') ? pairs#space() : ' '}

	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return Space()
	end

	let line = getline('.')
	let next = getline(nextnonblank(line('.')+1))
	let indent = autotype#indent(line)
	let next_indented = indent < autotype#indent(next)

	if line =~ '\v^\s*elif$'
		return " ; then\<esc>F;i"
	end

	if line =~ '\v^\s*if$'
		let seq = " ; then\<esc>F;i"
		if next !~ '\v^\s{'.indent.'}(fi|else|elif)$' && !next_indented
			return seq . "\<esc>ofi\<esc>k$F;i"
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

	return Space()
endf
