

" objects#synat(line:number, col:number) -> string
" Returns the syntax group at the given position.
func! objects#synat(line, col)
	return synIDattr(synIDtrans(synID(a:line, a:col, 0)), 'name')
endf


" objects#emptyline({line:number|string}) -> bool
" Returns whether or not the given {line} is empty. {line} can be either a line
" number or a string.
func! objects#emptyline(line)
	let line = type(a:line) == v:t_number ? getline(a:line) : a:line
	return line =~ '\v^\s*$'
endf


" objects#merge_dicts([{dict1:dictionary}, ...])
" Merge the given dictionaries.
func! objects#merge_dicts(...)
	let merged = {}
	for dict in a:000
		call extend(merged, dict, 'force')
	endfo
	return merged
endf


" objects#adjust_view({start:number}, {end:number}) -> 0
" Makes sure that when not all lines between {start} and {end} are visible, to
" move the line {start} to the top of the screen to maximize screen usage.
func! objects#adjust_view(start, end)
	let max_scroll = a:start - line('w0')
	let hidden_lines = max([a:end - line('w$'), 0])
	let scroll = min([hidden_lines, max_scroll])
	if scroll
		call feedkeys(scroll."\<c-e>", 'n')
	end
endf


" objects#enabled({object:string}) -> bool
" Returns wheter or not the user has enabled the given text object via the
" 'g:objects_enabled' option.
" Used in filetype plugins to determine whether automatically setup predefined
" mappings for the text objects.
"
" Examples:
"
" - g:objects_enabled = 1
"   The user has enabled all text objects.
"
" - g:objects_enabled = 0
"   The user has disabled all text objects (Default. Everything is opt-in)
"
" - g:objects_enabled = ['items', 'python']
"   the user has enabled all pytohn text objects and those defined in the
"   'items' class (See autoload/objects/items.vim)
"
" - g:objects_enabled = ['python', 'javascript#function']
"   The user has enabled all python text objects and the javascript function
"   text object (but not the other javascript text objects).
"
func! objects#enabled(object)
	return type(g:objects_enabled) == v:t_number && g:objects_enabled
	\ || type(g:objects_enabled) == v:t_list
	\ && !empty(filter(copy(g:objects_enabled), {-> a:object =~ '\v^'.v:val.'(#|$)'}))
endf


" objects#map({lhs:string}, {fn:string}[, {options:dict}]) -> 0
" Shortcut used to setup a mappings for the text objects.
"
" This function can be used inside .vimrc by users that want to use different
" mappings than those provided by default.
"
" Example:
"
" - call objects#map('af', 'objects#python#function', {'inner': 1})
"   This will setup a mapping 'af' for visual and operator-pending modes that
"   will call the predefined function 'objects#python#function' with the given
"   {options} to select the current python function.
"
func! objects#map(lhs, fn, ...)
	let options = a:0 && type(a:1) == v:t_dict ? a:1 : {}
	call s:map(0, a:lhs, function(a:fn, [options]))
endf


" objects#mapl({lhs:string}, {fn:string}[, args]) -> 0
" Like objects#map(..) but setup a mapping only locally to the current buffer.
" For this reason it is expected to only be called in filetype plugins or with
" `autocmd FileType <x> call objects#mapl(..)`
func! objects#mapl(lhs, fn, ...)
	let options = a:0 && type(a:1) == v:t_dict ? a:1 : {}
	call s:map(1, a:lhs, function(a:fn, [options]))
endf


" s:map({local:bool}, {lhs:string}, {fn:funcref}) -> 0
" Function used to actually setup mappings for the text objects.
" When {local} is true, the map will be local to the current buffer.
"
" In visual mode, we abort the selection with an initial <esc> to make sure the
" cursor position remains in the current position instead of being moved to the
" top of the selection. For this reason we also need to use <expr> to grab the
" correct v:count1 value, otherwise it would always be 1.
"
func! s:map(local, lhs, fn)
	let buffer = a:local ? "<buffer>" : ""
	exec "vnoremap <expr> <silent>" buffer a:lhs printf('"<esc>:<c-u>call %s(1, ".v:count1.")<cr>"', a:fn)
	exec "onoremap <silent>" buffer a:lhs printf(":call %s(0, v:count1)<cr>", a:fn)
endf
