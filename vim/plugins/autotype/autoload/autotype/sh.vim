

func! autotype#sh#outward_parenthesis()
	let Paren = {-> exists('*pairs#insert_paren') ? pairs#insert_paren('(') : '('}

	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return Paren()
	end

	let before = autotype#before()
	let empty_after = autotype#after() =~ '\v^\s*$'

	if before =~ '\v\c^\s*[a-z0-9:_-]+$' && empty_after
		return "(\<esc>m`a) {\<cr>}\<esc>O"
	end

	return Paren()
endf


func! autotype#sh#space()
	let Space = {-> exists('*pairs#space') ? pairs#space() : ' '}

	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return Space()
	end

	let before = autotype#before()
	let empty_after = autotype#after() =~ '\v^\s*$'

	if before =~ '\v^\s*if$' && empty_after
		let seq = " ; then\<esc>F;i"
		return s:should_close_with('fi') ? seq."\<esc>ofi\<esc>k$F;i" : seq
	end

	if before =~ '\v^\s*elif$' && empty_after
		return " ; then\<esc>F;i"
	end

	if before =~ '\v^\s*case$' && empty_after
		let seq = "  in\<esc>bhi"
		return s:should_close_with('esac') ? seq."\<esc>oesac\<esc>k$bhi" : seq
	end

	if before =~ '\v^\s*(while|for)$' && empty_after
		let seq = " ; do\<esc>F;i"
		return s:should_close_with('done') ? seq."\<esc>odone\<esc>k$F;i" : seq
	end

	return Space()
endf


func! s:should_close_with(end)
	let indent = autotype#indent('.')
	let next = getline(nextnonblank(line('.')+1))
	return next !~ '\v^\s{'.indent.'}'.a:end.'$' && next !~ '\v^\s{'.(indent+1).',}\w+'
endf
