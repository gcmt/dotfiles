

" See ~/.config/ranger/plugins/choose.py
let s:cmd = 'choose'


let s:default_bindings = {
	\ 'l': 'window', 'ee': 'window',
	\ 'es': 'split', 'ev': 'vsplit',
	\ 'et': 'tab'
\ }


let s:no_preview = [
	\ "--cmd='set column_ratios 1'",
	\ "--cmd='set preview_files false'",
	\ "--cmd='set preview_directories false'",
	\ "--cmd='set collapse_preview true'",
\ ]


" ranger#open({target:string}[, {external:int}]) -> 0
" Open the file/directory {target} in ranger. If {external} is given and it's
" true, ranger is executed in an external terminal specified in the option
" 'g:ranger_termprg', otherwise ranger is excuted in a terminal using
" term_start().
func! ranger#open(target, ...)

	let external = a:0 && a:1
	let out_file = tempname()

	let cmd  = ['ranger']
	let cmd += ['--choosefiles='.out_file]
	let cmd += s:bindings()

	" Hide the preview column when the window is too small
	if &columns < g:ranger_preview_treshold
		let cmd += s:no_preview
	end

	" Must be the last argument before executing the command
	if filereadable(a:target)
		let cmd += ['--selectfile='.shellescape(a:target)]
	else
		let cmd += [fnamemodify(a:target, ':p:h')]
	end

	let exit_cb_ctx = {
		\ 'cmd': cmd,
		\ 'callback': funcref('s:callback'),
		\ 'out_file': out_file,
		\ 'curwin': winnr(),
		\ 'laststatus': &laststatus,
	\ }

	if external

		sil call system(join([g:ranger_term_prg] + ['-e'] + cmd))
		call call('s:exit_cb', [-1, v:shell_error], exit_cb_ctx)

	else

		au TerminalOpen * ++once setl laststatus=0

		let job_opts = {
			\ 'exit_cb': funcref('s:exit_cb', [], exit_cb_ctx),
			\ 'term_finish': 'close',
			\ 'term_kill': 'term',
		\ }

		call term_start(['sh', '-c', join(cmd)], job_opts)

	end

endf


" s:exit_cb({job}, {status:int}) -> 0
" Function responsible to parse the ranger output file and call the callback
" function with the file selection and the opening mode.
" The first line of the output file is expected to have the the format
" '#meta mode=<mode>'.
func! s:exit_cb(job, status) dict

	let &laststatus = self.laststatus
	exec self.curwin . 'wincmd w'

	let ctx = {
		\ 'cmd': self.cmd,
		\ 'status': a:status,
		\ 'selection': [],
		\ 'mode': '',
	\ }

	if filereadable(self.out_file)
		let lines = readfile(self.out_file)
		if get(lines, 0, '') =~ '\v^#meta'
			let ctx['mode'] = matchstr(lines[0], '\v<mode\=\zs\w+')
			let lines = lines[1:]
		end
		let ctx['selection'] = lines
	end

	call funcref(self.callback, [], ctx)()

endf


" s:callback() -> 0
" Callback function called to process the selected files.
func! s:callback() dict

	if self.status
		return s:err("Command failed with error %d: %s", self.status, self.cmd)
	end

	if empty(self.selection)
		return
	end

	call map(self.selection, {i, v -> fnameescape(v)})

	if len(self.selection) > 1
		exec 'argadd' join(self.selection)
	end

	let commands = {
		\ 'window': '',
		\ 'tab': 'tab split',
		\ 'split': 'split',
		\ 'vsplit': 'vsplit',
	\ }

	sil exec get(commands, self.mode, '')
	exec 'edit' self.selection[0]

	redraw!

endf


" s:bindings() -> list
" Return custom ranger bindings.
func! s:bindings()
	let bindings = []
	for [k, v] in items(s:default_bindings)
		call add(bindings, printf("--cmd='map %s %s mode=%s'", k, s:cmd, v))
	endfo
	return bindings
endf


" s:err({fmt:string}, [{expr1:any}, ...]) -> 0
" Display a error message.
func! s:err(fmt, ...)
	echohl WarningMsg | echom call('printf', [a:fmt] + a:000)  | echohl None
endf
