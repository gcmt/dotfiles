
" See ~/.config/ranger/commands.py
let s:edit_cmd = 'vim_edit'

let s:no_preview = [
	\ "--cmd='set column_ratios 1'",
	\ "--cmd='set preview_files false'",
	\ "--cmd='set preview_directories false'",
	\ "--cmd='set collapse_preview true'",
\ ]

" ranger#open({target:string}[, {external:int}]) -> 0
" Open the file/directory {target} in ranger. If {external} is given and it's
" true, ranger is executed in an external terminal specified in the option
" 'g:ranger_termprg', otherwise ranger is excuted in the current terminal.
func! ranger#open(target, ...)
	let external = a:0 && a:1
	let tmp = tempname()
	let cmd  = ['ranger']
	let cmd += ['--choosefiles='.tmp]
	let cmd += s:bindings()
	" Hide the preview column when the window is too small
	if !external && &columns < g:ranger_preview_treshold
		let cmd += s:no_preview
	end
	" Must be the last argument before executing the command
	let target = shellescape(a:target)
	let cmd += filereadable(a:target) ? ['--selectfile='.target] : [target]
	if external
		sil call system(join([g:ranger_term_prg] + ['-e'] + cmd))
	else
		sil exec '!' . join(cmd)
	end
	if v:shell_error
		return s:err(printf("Command failed with error %d: %s", v:shell_error, join(cmd)))
	end
	if filereadable(tmp)
		call s:open_files(tmp)
		call delete(tmp)
	end
	redraw!
endf

" s:open_files({tmp:string}) -> 0
" Open files written by ranger in the file {tmp}.
" The first line will have the format '#mode mode' to indicate how the file (or
" the first file of the selection) should be opened (see vim_edit function at
" .config/ranger/commands.py)
" Possible modes are: window, slit, vsplit, tab.
func! s:open_files(tmp)
	let mode = ''
	let files = readfile(a:tmp)
	if get(files, 0, '') =~ '\v^#meta'
		let mode = matchstr(files[0], '\v<mode\=\zs\w+')
		let files = files[1:]
	end
	let files = map(files, {i, v -> fnameescape(v)})
	if empty(files)
	end
	if empty(files)
		return s:err("No files to open.")
	end
	if len(files) > 1
		exec 'argadd' join(files)
	end
	let commands = {
		\ 'window': '',
		\ 'tab': 'tab split',
		\ 'split': 'split',
		\ 'vsplit': 'vsplit',
	\ }
	sil exec get(commands, mode, '')
	exec 'edit' files[0]
endf

" s:bindings() -> list
" Return edit bindings.
func! s:bindings()
	let bindings = []
	for [key, mode] in items(g:ranger_bindings)
		call add(bindings, printf("--cmd='map %s %s mode=%s'", key, s:edit_cmd, mode))
	endfo
	return bindings
endf

" s:err({msg:string}) -> 0
" Display a simple error message.
func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
