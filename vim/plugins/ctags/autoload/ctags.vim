
" All currently running jobs
" {pid: {job-channel, job-errors, tagfile}, ..}
let s:jobs = {}

" Anything logged
let s:logs = []

" ctags#log() -> string
" Print the logs.
func ctags#print_log()
	for entry in s:logs
		let msg = printf("[%s] %s", entry.timestamp, entry.message)
		let group = entry.lvl == 'error' ? 'ErrorMsg' : 'Normal'
		exec "echohl" group "| echo msg | echohl None"
	endfo
endf

" ctags#run() -> 0
" Automatically generate tags for the current working directory
" if all the conditions are met.
func ctags#run()
	call s:load_options()
	if empty(&filetype) || !empty(&buftype)
		return
	end
	let dir = getcwd()
	let tagfile = call(g:ctags.tagfile, [])
	if !filereadable(s:joinpaths(dir, tagfile))
		return
	end
	let options = s:ctags_options()
	call s:run(getcwd(), tagfile, options)
endf

" s:load_options() -> 0
" Load options defined by the user via the g:ctags dictionary and merge them
" with default options.
" Doing this on every run allows the user to change options at runtime.
func s:load_options()
	let g:ctags = extend(get(g:, 'ctags', {}), {
		\ 'options': {-> ['-Rn', '--languages='.&filetype]},
		\ 'tagfile': {-> isdirectory('.tags') ? printf('.tags/%s/0.project', &ft) : 'tags'},
	\ }, 'force')
endf

" s:run({dir:string}, {tagfile:string}, {options:list}) -> 0
" Asynchronously generate tags for the directory {dir} and store
" them to {tagfile}, which is expected to be a path relative to {dir}.
" When trying to write to a tagfile a job is already trying to write to,
" the current execution is queued.
func s:run(dir, tagfile, options) abort
	let dest = s:joinpaths(a:dir, a:tagfile)
	for pid in keys(s:jobs)
		if s:jobs[pid].tagfile == dest
			" If a job running ctags is already trying to write to {dest},
			" then queue the current execution
			call s:log('info', printf("ctags queued for %s (tagfile busy: %s)", a:dir, dest))
			let s:jobs[pid].after = funcref('s:run', [a:dir, a:tagfile, a:options])
			return
		end
	endfo
	let cmd = ['ctags'] + a:options + ['-f', dest, a:dir]
	let context = {
		\ 'dir': a:dir,
		\ 'cmd': join(cmd),
		\ 'tagfile': dest,
		\ 'start_time': reltime(),
	\ }
	let job = job_start(cmd, {
		\ 'exit_cb': funcref('s:exit_cb', [], context),
		\ 'err_cb': funcref('s:err_cb'),
	\ })
	let info = job_info(job)
	call s:log('info', printf("[%s] ctags started: %s", info.process, join(cmd)))
	let s:jobs[info.process] = {
		\ 'channel': info.channel,
		\ 'tagfile': dest,
		\ 'errors': [],
	\ }
endf

" s:exit_cb({job:job}, {status:number}) -> 0
" Callback for when the ctags job ends. The arguments are the ctags {job} and
" the exit {status}. See :h job-exit_cb.
" This function is expected to be executed with a context.
" If another execution has being queued, it is executed at the end.
func s:exit_cb(job, status) dict
	let pid = job_info(a:job).process
	if a:status != 0
		call s:log('error', printf("[%s] ctags failed (%s): %s", pid, a:status, self.cmd))
		for err in s:jobs[pid].errors
			call s:log('error', printf("[%s] error: %s", pid, err))
		endfo
		call s:err("Failed to generate tags for " . self.dir)
	else
		let elapsed = reltime(self.start_time)
		let seconds = substitute(reltimestr(elapsed), '\v\s+', '', 'g')
		call s:log('info', printf("[%s] tags generated in %ss: %s", pid, seconds, self.tagfile))
	end
	let After = get(s:jobs[pid], 'after', {->0})
	unlet! s:jobs[pid]
	call After()
endf

" s:err_cb({channel:channel, {message:string}) -> 0
" Callback for when there is something to read on stderr.
func s:err_cb(channel, message)
	for pid in keys(s:jobs)
		if s:jobs[pid].channel == a:channel
			call add(s:jobs[pid].errors, a:message)
			return
		end
	endfo
endf

" s:ctags_options() -> list
" Return all options for the ctags command.
func s:ctags_options()
	let options = []
	let options += s:eval_options(get(g:ctags, 'options', []))
	let options += s:eval_options(get(g:ctags, &filetype.'_options', []))
	return options
endf

" s:eval_options({options:list|funcref|string}) -> list
" Translate options to list type.
func s:eval_options(options)
	if type(a:options) == v:t_func
		let options = call(a:options, [])
	else
		let options = a:options
	end
	if type(options) == v:t_list
		return options
	elseif type(options) == v:t_string
		return split(options)
	else
		throw "Ctags: Bad options: " . string(options)
	end
	return []
endf

" s:joinpaths([{pathN:string}, ...]) -> string
" Join paths. Trailing slashes are trimmed.
func s:joinpaths(...)
	let args = filter(copy(a:000), {-> !empty(v:val)})
	let path = substitute(join(args, '/'), '\v/+', '/', 'g')
	return substitute(path, '\v/+$', '', '')
endf

" s:log({lvl:string}, {message:string}) -> 0
" Log a {message} with level {lvl}.
func s:log(lvl, message)
	let time = strftime('%T', reltimestr(reltime()))
	let entry = {'timestamp': time, 'lvl': a:lvl, 'message': a:message}
	call add(s:logs,  entry)
endf

" s:err({message:string}) -> 0
" Display an error {message}.
func s:err(message)
	echohl WarningMsg | echom a:message | echohl None
endf
