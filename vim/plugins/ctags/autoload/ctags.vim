
" A list of argument lists to pass to s:run(..) (will hold only one item)
let s:queue = []

" The currently running job
let s:job = 0

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
" When a job is already running, the current execution is queued.
func s:run(dir, tagfile, options) abort
	if s:ctags_running()
		let s:queue = [[a:dir, a:tagfile, a:options]]
		return
	end
	let dest = s:joinpaths(a:dir, a:tagfile)
	let cmd = ['ctags'] + a:options + ['-f', dest, a:dir]
	let context = {
		\ 'dir': a:dir,
		\ 'cmd': join(cmd),
		\ 'tagfile': dest,
		\ 'start_time': reltime(),
	\ }
	call s:log('info', "Generating tags for " . a:dir)
	call s:log('info', "Command: " . join(cmd))
	let s:job = job_start(cmd, {
		\ 'exit_cb': funcref('s:exit_cb', [], context),
	\ })
endf

" s:ctags_running() -> number
" Return whether or not ctags is currently running.
func s:ctags_running()
	return type(s:job) == v:t_job && job_status(s:job) == 'run'
endf

" s:exit_cb({job:job}, {status:number}) -> 0
" Callback for when the job ends. The arguments are the
" {job} and the exit {status}. See :h job-exit_cb.
" This function is expected to be executed with a context.
func s:exit_cb(job, status) dict
	if a:status != 0
		call s:log('error', "Failed to generate tags for " . self.dir)
		call s:log('error', "Command: " . self.cmd)
		call s:log('error', "Exit code: " . a:status)
		call s:err("Failed to generate tags for " . self.dir)
	else
		let elapsed = reltime(self.start_time)
		let seconds = substitute(reltimestr(elapsed), '\v\s+', '', 'g')
		call s:log('info', printf("Tags generated for %s in %ss (%s)", self.dir, seconds, self.tagfile))
	end
	if !empty(s:queue)
		call call('s:run', remove(s:queue, -1))
	end
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
