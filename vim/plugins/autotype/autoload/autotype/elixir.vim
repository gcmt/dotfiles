
func! autotype#elixir#setup()
	inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=autotype#elixir#space()<cr>
	inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=autotype#elixir#esc_o()<cr>
endf

func! autotype#elixir#space()
	let line = getline('.')
	let Space = {-> exists('*pairs#space') ? pairs#space() : ' '}
	if g:autotype_disabled || autotype#inside('String', 'Comment') || s:nextline_indented()
		return Space()
	end
	let after = autotype#after()
	if line =~ '\v^\s*def' && line =~ '\v,$' && after =~ '\v^\s*$'
		return ' do: '
	end
	return Space()
endf

fun! autotype#elixir#esc_o()
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
	let indent = indent(line('.'))
	let nextline = getline(line('.')+1)
	return nextline =~ '\v^'.repeat('\s', indent).'end'
endf

fun! s:nextline_indented()
	let indent = indent(line('.'))
	let nextline = getline(line('.')+1)
	return nextline =~ '\S' && indent < indent(line('.')+1)
endf

fun! s:is_inline_function()
	return getline('.') =~ '\v\),\sdo:\s'
endf
