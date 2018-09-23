

func! autotype#sh#outward_parenthesis()
	let Paren = {-> exists('*pairs#insert_paren') ? pairs#insert_paren('(') : '('}

	if g:autotype_disabled || autotype#inside('String', 'Comment')
		return Paren()
	end

	let before = autotype#before()

	if autotype#after() !~ '\v^\s*$'
		return Paren()
	end

	if before =~ '\v\c^\s*[a-z0-9:_-]+$'
		return "(\<esc>m`a) {\<cr>}\<esc>O"
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
	let indent = autotype#indent('.')
	let next_indented = next =~ '\v^\s{'.(indent+1).',}\w+'

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
