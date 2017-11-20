
" Clear undo history (:h clear-undo)
fun! utils#clear_undo()
	let modified_save = &modified
	let undolevels_save = &undolevels
	let line_save = getline('.')
	set undolevels=-1
	exec "norm! a \<bs>\<esc>"
	call setline('.', line_save)
	let &undolevels = undolevels_save
	let &modified = modified_save
endf

" Find project root
fun! utils#find_root(path)
	if empty(a:path) || a:path == '/'
		return ''
	end
	let files = glob(a:path.'/.*', 1, 1) + glob(a:path.'/*', 1, 1)
	let pattern = '\V\^\(' . join(get(g:, 'root_markers', []), '\|') . '\)\$'
	if match(map(files, "fnamemodify(v:val, ':t')"), pattern) >= 0
		return a:path
	end
	return utils#find_root(fnamemodify(a:path, ':h'))
endf

" Cd into the current project root
fun! utils#cd_into_root(bang)
	let path = utils#find_root(expand('%:p:h'))
	if !empty(path)
		let cmd = empty(a:bang) ? 'cd' : 'lcd'
		exec cmd fnameescape(path)
		pwd
	end
endf

" Execute the :s command without messing jumps or cursor
fun! utils#s(pattern, string, flags)
	let view = winsaveview()
	sil! exec 'keepj' 'keepp' '%s/'.a:pattern.'/'.a:string.'/'.a:flags
	call winrestview(view)
endf

" Execute zz when jumping offscreen and show cursorline
fun! utils#zz(bang, expr)
	let top_line = line('w0') + 1
	let bottom_line = line('w$') - 1
	try
		exec a:expr =~ '\v^:' ? a:expr[1:] : 'norm! '.a:expr
		let @/ = histget('/', -1) " :h function-search-undo
		if !empty(a:bang)
			set cursorline
		end
	catch
		let error = matchstr(v:exception, '\vE\d+:.*')
		echohl ErrorMsg | echo error | echohl None
	endtry
	if line('.') < top_line || line('.') > bottom_line
		norm! zz
	end
endf

" Search for current word or selected text without moving the cursor
fun! utils#search(visual)
	if a:visual
		let selection = getline('.')[col("'<")-1:col("'>")-1]
		let pattern = '\V' . escape(selection, '/\')
	else
		let pattern = '\<' . expand('<cword>') . '\>'
	end
	let @/ = pattern
	call histadd('/', pattern)
endf

" Rename the current buffer
fun! utils#rename_buffer(bang, new_name)
	let alternate_save = @#
	try
		exec 'saveas'.a:bang fnameescape(expand('%:p:h'). '/' . a:new_name)
		call delete(expand('#:p'))
		sil exec 'bwipe' fnameescape(expand('#:p'))
	catch
		let msg = substitute(v:exception, '\v^Vim\([^:]*:', '', '')
		echohl WarningMsg | echo msg | echohl None
	finally
		let @# = alternate_save
	endtry
endf

" Resize current window using percentages
fun! utils#resize_window(args)
	let args = a:args
	if winheight(0) == &lines - &cmdheight - 1
		" assume vertical resizing when the window spans
		" the entire vim window height
		let args .= ' -v'
	end
	let n = str2nr(matchstr(args, '\v\d+'))
	let x = args =~ '\v<-?v>' ? &columns : &lines
	let vertical = args =~ '\v<-?v>' ? 'vertical' : ''
	exec vertical 'resize' (float2nr(x * n) / 100)
endf

fun! utils#zoom_toggle() abort
	if exists('w:zoom')
		exec w:zoom
		unlet w:zoom
	else
		let w:zoom = winrestcmd()
		wincmd _
		wincmd |
	end
endf

" Returns the syntax group under the cursor
fun! utils#syntax()
	return synIDattr(synIDtrans(synID(line('.'), col('.'), 0)), 'name')
endf
