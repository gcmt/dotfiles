
" ranger#open({target:string}) -> 0
" Open {target} in ranger. If {target} is a file then ranger will show the file
" location.
func! ranger#open(target)
	let tmp = tempname()
	let target = shellescape(a:target)
	let cmd  = ['!ranger']
	let cmd += ['--choosefiles='.tmp]
	if &columns < g:ranger_preview_treshold
		let cmd += ["--cmd='set column_ratios 1'"]
		let cmd += ["--cmd='set preview_files false'"]
		let cmd += ["--cmd='set preview_directories false'"]
		let cmd += ["--cmd='set collapse_preview true'"]
	end
	if filereadable(a:target)
		let cmd += ['--selectfile='.target]
	else
		let cmd += [target]
	end
	sil exec join(cmd)
	if v:shell_error
		echoerr "Command failed with error" v:shell_error.":" join(cmd)
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
