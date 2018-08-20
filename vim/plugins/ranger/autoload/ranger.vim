
" ranger#open({target:string}[, {external:int}]) -> 0
" Open the file/directory {target} in ranger. If {external} is given and it's
" true, ranger is executed in an external terminal specified in the option
" 'g:ranger_termprg', otherwise ranger is excuted in the current terminal.
func! ranger#open(target, ...)
	let external = a:0 > 0 && a:1
	let tmp = tempname()
	let cmd  = ['ranger']
	let cmd += ['--choosefiles='.tmp]
		" Hide the preview column when the window is too small
	if !external && &columns < g:ranger_preview_treshold
		let cmd += ["--cmd='set column_ratios 1'"]
		let cmd += ["--cmd='set preview_files false'"]
		let cmd += ["--cmd='set preview_directories false'"]
		let cmd += ["--cmd='set collapse_preview true'"]
	end
	" Must be the last argument before executing the command
	let target = shellescape(a:target)
	let cmd += filereadable(a:target) ? ['--selectfile='.target] : [target]
	if external
		sil call system(join([g:ranger_termprg] + ['-e'] + cmd))
	else
		sil exec '!' . join(cmd)
	end
	if v:shell_error
		echoerr printf("Command failed with error %d: %s", v:shell_error, join(cmd))
	end
	if filereadable(tmp)
		let files = map(readfile(tmp), {i, v -> fnameescape(v)})
		if len(files) > 1
			exec 'argadd' join(files)
		end
		exec 'edit' files[0]
		call delete(tmp)
	end
	redraw!
endf
