
" A list of argument lists to pass to ctags#run (will hold only one item)
let s:queue = []

" The currently running job
let s:job = 0

" Anything logged
let s:log = []

" ctags#run({dir:string}, {tagfile:string}, {options:list}) -> 0
" Asynchronously generate tags for the directory {dir} and store
" them to {tagfile}, which is expected to be a path relative to {dir}.
" When a job is already running, the current execution is queued.
func ctags#run(dir, tagfile, options) abort
	if s:ctags_running()
		let s:queue = [[a:dir, a:tagfile, a:options]]
		return
	end
	let dest = ctags#joinpaths(a:dir, a:tagfile)
	let cmd = ['ctags'] + a:options + ['-f', dest, a:dir]
	let context = {
		\ 'dir': a:dir,
		\ 'cmd': join(cmd),
		\ 'start_time': reltime(),
	\ }
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
	let timestamp = strftime('%T', reltimestr(reltime()))
	if a:status != 0
		call s:log(printf("[%s] Error: %s (exit code: %d)", timestamp, self.cmd, a:status))
		call s:err("Failed to generate tags for: " . self.dir)
	else
		let elapsed = reltime(self.start_time)
		let seconds = substitute(reltimestr(elapsed), '\v\s+', '', 'g')
		call s:log(printf("[%s] Tags successfully generted for %s in %ss", timestamp, self.dir, seconds))
	end
	if !empty(s:queue)
		call call('ctags#run', remove(s:queue, -1))
	end
endf

" ctags#joinpaths([{pathN:string}, ...]) -> string
" Join paths. Trailing slashes are trimmed.
func ctags#joinpaths(...)
	let args = filter(copy(a:000), {-> !empty(v:val)})
	let path = substitute(join(args, '/'), '\v/+', '/', 'g')
	return substitute(path, '\v/+$', '', '')
endf

" ctags#log() -> string
" Return the log.
func ctags#log()
	return join(s:log, "\n")
endf

" s:log({message:string}) -> 0
" Log the given {message}.
func s:log(message)
	call extend(s:log, split(a:message, "\n"))
endf

" s:err({message:string}) -> 0
" Display an error {message}.
func s:err(message)
	echohl WarningMsg | echom a:message | echohl None
endf
