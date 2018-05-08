
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

" rofi#err({msg:string}) -> 0
" Display a simple error message.
func rofi#err(msg)
	echohl WarningMsg | echom a:msg | echohl None
endf
