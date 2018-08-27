
" objects#synat(['.' | [{line:number}, {col:number}]]) -> string
" Returns the syntax group at the given position.
" When the only argument is the '.' expression, the syntax at the current cursor
" position is returned.
func! objects#synat(...)
	if a:0 == 1 && type(a:1) == v:t_string && a:1 == '.'
		let [line, col] = [line('.'), col('.')]
	elseif a:0 == 1 && type(a:1) == v:t_list
		let [line, col] = a:1
	elseif a:0 == 2 && type(a:1) == v:t_number && type(a:2) == v:t_number
		let [line, col] = [a:1, a:2]
	else
		throw "Wrong arguments for function: objects#synat"
	end
	return synIDattr(synIDtrans(synID(line, col, 0)), 'name')
endf


" objects#emptyline({line:number|string}) -> bool
" Returns whether or not the given {line} is empty. {line} can be either a line
" number or a string.
func! objects#emptyline(line)
	let line = type(a:line) == v:t_number ? getline(a:line) : a:line
	return line =~ '\v^\s*$'
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
	let object = split(a:object, '#')
	return type(g:objects_enabled) == v:t_number && g:objects_enabled
	\ || type(g:objects_enabled) == v:t_list
	\ && (index(g:objects_enabled, a:object) != -1
			\ || len(object) == 2 && index(g:objects_enabled, object[0]) != -1)
endf


" objects#map({lhs:string}, {fn:string}[, args]) -> 0
" Shortcut used to setup a mappings for the text objects.
"
" This function can be used inside .vimrc by users that want to use different
" mappings than those provided by default.
"
" Example:
"
" - call objects#map('af', 'objects#python#function', {'inner': 1})
"   This will setup a mapping 'af' for visual and operator-pending modes that
"   will call the predefined function 'objects#python#function' to select the
"   current python function. All these functions are defined at the top of each
"   autoload/objects/* file.
"   The remaining arguments will be passed to the function. The amount and type
"   of arguments will depend on the specific function implementation.
"
func! objects#map(lhs, fn, ...)
	call s:map(0, a:lhs, function(a:fn, a:000))
endf


" objects#mapl({lhs:string}, {fn:string}[, args]) -> 0
" Like objects#map(..) but setup a mapping only locally to the current buffer.
" For this reason it is expected to only be called in filetype plugins.
func! objects#mapl(lhs, fn, ...)
	call s:map(1, a:lhs, function(a:fn, a:000))
endf


" s:map({local:bool}, {lhs:string}, {fn:funcref}) -> 0
" Function used to actually setup mappings for the text objects.
" When {local} is true, the map will be local to the current buffer.
func! s:map(local, object, fn)
	let buffer = a:local ? "<buffer>" : ""
	exec "vnoremap <silent>" buffer a:object printf(":<c-u>call %s()<cr>", a:fn)
	exec "onoremap <silent>" buffer a:object printf(":<c-u>exec 'norm v'.v:count1.'%s'<cr>", a:object)
endf
