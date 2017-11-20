
fun! flow#elixir#space()
	let line = getline('.')
	if g:flow_disabled || flow#inside('String', 'Comment') || s:nextline_indented()
		return exists('g:loaded_pairs') ? pairs#space() : ' '
	end
	let after = flow#after()
	if line =~ '\v^\s*def' && line =~ '\v,$' && after =~ '\v^\s*$'
		return ' do: '
	end
	return exists('g:loaded_pairs') ? pairs#space() : ' '
endf

fun! flow#elixir#newline()
	let line = getline('.')
	if line =~ '\v^\s*def' && line !~ '\v<do$' && !s:is_inline_function()
		call setline(line('.'), substitute(line, '\v\s*$', ' do', ''))
		if !s:nextline_end() && !s:nextline_indented()
			return "\<esc>oend\<esc>O"
		end
	end
	return "\<esc>o"
endf

fun! s:nextline_end()
	let indent = flow#indent('.')
	let nextline = getline(line('.')+1)
	return nextline =~ '\v^'.repeat('\s', indent).'end'
endf

fun! s:nextline_indented()
	let indent = flow#indent('.')
	let nextline = getline(line('.')+1)
	return nextline =~ '\S' && indent < flow#indent(line('.')+1)
endf

fun! s:is_inline_function()
	return getline('.') =~ '\v\),\sdo:\s'
endf
