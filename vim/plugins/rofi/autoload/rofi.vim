
" rofi#width() -> number
" Determine the right rofi width according to predefined rules.
func rofi#width() abort
	let width = g:rofi_default_width
	for rule in g:rofi_width_rules
		if rule[0] =~ '\v^\s*((\<|\>)\=?|\=\=)\s*\d+\s*$' && eval('&columns' . rule[0])
			let width = rule[1]
		end
	endfo
	return width
endf

" rofi#get_color({group:string}) -> string
" Return the color value for the given highlight group.
func rofi#get_color(group) abort
	let group = a:group
	while 1
		let hi = execute('hi ' . group)
		let linked = matchstr(hi, '\vlinks to \zs\w+')
		if !empty(linked)
			let group = linked
		else
			return matchstr(hi, '\v#[0-9a-fA-F]+')
		end
	endw
endf

" rofi#err({msg:string}) -> 0
" Display a simple error message.
func rofi#err(msg)
	echohl WarningMsg | echom a:msg | echohl None
endf
