

" All currently running jobs
" {id: {pid, errors, tagfile}, ..}
let s:jobs = {}

" Anything logged
let s:logs = []


" ctags#logs() -> string
" Print the logs.
func ctags#logs()
	for entry in s:logs
		let msg = printf("[%s] %s", entry.timestamp, entry.message)
		let group = entry.lvl == 'error' ? 'ErrorMsg' : 'Normal'
		exec "echohl" group "| echo msg | echohl None"
	endfo
endf

" ctags#run({filetypes:string}, {force:bool}) -> 0
" Generate tags for the current working directory for the given {filetypes}. If
" no {filetypes} are given then use the current buffer filetype. If {Force} is
" true, then an empty tag file is created and tags get generated.
func ctags#run(filetypes, force) abort

	let filetypes = split(a:filetypes)

	if empty(filetypes) && !empty(&filetype) && empty(&buftype)
		call add(filetypes, &filetype)
	end

	if empty(filetypes) && a:force
		return s:err("Invalid buffer")
	end

	if empty(filetypes)
		return
	end

	let ft_target = remove(filetypes, 0)
	let ctx = {'ft': ft_target}
	call s:load_options(ctx)

	let cwd = getcwd()
	let tagfile = s:joinpaths(cwd, g:ctags.tagfile)
	if !filereadable(tagfile)
		if a:force
			if len(split(tagfile, '/')) > 1
				call mkdir(fnamemodify(tagfile, ':h'), 'p')
			end
			call system('touch ' . shellescape(tagfile))
			call s:log("info", "Created tagfile %s", tagfile)
		else
			return
		end
	end

	let options = s:ctags_options(ft_target)
	call s:run(getcwd(), g:ctags.tagfile, options)

	if !empty(filetypes)
		call ctags#run(join(filetypes), a:force)
	end

endf


" s:load_options({ctx:dict}) -> 0
" Load options defined by the user via the g:ctags dictionary and merge them
" with default options. {ctx} is dictionary passed as argument to all
" function-type options.
func s:load_options(ctx) abort

	let g:ctags = extend(get(g:, 'ctags', {}), {
		\ 'options': {ctx -> ['-Rn', '--languages='.a:ctx.ft]},
		\ 'tagfile': {ctx -> isdirectory('.tags') ? printf('.tags/%s/0.project', a:ctx.ft) : 'tags'},
	\ }, 'force')

	if type(g:ctags.tagfile) == v:t_func
		let g:ctags.tagfile = call(g:ctags.tagfile, [a:ctx])
	end

	if type(g:ctags.tagfile) != v:t_string
		 throw "Ctags: Invalid tagfile: " . string(g:ctags.tagfile)
	end

	if type(g:ctags.options) == v:t_func
		let g:ctags.options = call(g:ctags.options, [a:ctx])
	end

	if type(g:ctags.options) != v:t_list
		 throw "Ctags: Invalid options: " . string(g:ctags.options)
	end

endf


" s:ctags_options({filetype:string}) -> list
" Return all options for the ctags command.
func s:ctags_options(filetype)
	let options  = []
	let options += get(g:ctags, 'options', [])
	let options += get(g:ctags, a:filetype.'_options', [])
	return options
endf


" s:run({dir:string}, {tagfile:string}, {options:list}) -> 0
" Asynchronously generate tags for the directory {dir} and store
" them to {tagfile}, which is expected to be a path relative to {dir}.
" When trying to write to a tagfile a job is already trying to write to,
" the current execution is queued.
func s:run(dir, tagfile, options) abort

	let dest = s:joinpaths(a:dir, a:tagfile)

	for id in keys(s:jobs)
		if s:jobs[id].tagfile == dest
			" If a job running ctags is already trying to write to {dest},
			" then queue the current execution
			call s:log('info', "ctags queued for %s (already writing to %s)", a:dir, dest)
			let s:jobs[id].after = funcref('s:run', [a:dir, a:tagfile, a:options])
			return
		end
	endfo

	let id = s:id()
	let cmd = ['ctags'] + a:options + ['-f', dest, a:dir]

	let exit_cb_ctx = {
		\ 'id': id,
		\ 'dir': a:dir,
		\ 'cmd': join(cmd),
		\ 'tagfile': dest,
		\ 'start_time': reltime(),
	\ }

	let err_cb_ctx = {
		\ 'id': id,
	\ }

	let job = job_start(cmd, {
		\ 'exit_cb': funcref('s:exit_cb', [], exit_cb_ctx),
		\ 'err_cb': funcref('s:err_cb', [], err_cb_ctx),
	\ })

	let info = job_info(job)
	let s:jobs[id] = {'pid': info.process, 'tagfile': dest, 'errors': []}
	call s:log('info', "[%s] ctags started: %s", info.process, join(cmd))

endf


" s:exit_cb({job:job}, {status:number}) -> 0
" Callback for when the ctags job ends. The arguments are the ctags {job} and
" the exit {status}. See :h job-exit_cb.
" If another execution has being queued, it is executed at the end.
" This function is expected to be executed with a context.
func s:exit_cb(job, status) dict

	let pid = job_info(a:job).process

	if a:status != 0
		call s:log('error', "[%s] ctags failed (%s): %s", pid, a:status, self.cmd)
		for err in s:jobs[self.id].errors
			call s:log('error', "[%s] error: %s", pid, err)
		endfo
		call s:err("Failed to generate tags for %s", self.dir)
	else
		let elapsed = reltime(self.start_time)
		let seconds = substitute(reltimestr(elapsed), '\v\s+', '', 'g')
		call s:log('info', "[%s] tags generated in %ss: %s", pid, seconds, self.tagfile)
	end

	let After = get(s:jobs[self.id], 'after', {->0})
	unlet! s:jobs[self.id]
	call After()

endf


" s:err_cb({ch:channel, {message:string}) -> 0
" Callback for when there is something to read on stderr.
" This function is expected to be executed with a context.
func s:err_cb(ch, message) dict
	call add(s:jobs[self.id].errors, a:message)
endf


" s:joinpaths([{pathN:string}, ...]) -> string
" Join paths. Trailing slashes are trimmed.
func s:joinpaths(...)
	let args = filter(copy(a:000), {-> !empty(v:val)})
	let path = substitute(join(args, '/'), '\v/+', '/', 'g')
	return substitute(path, '\v/+$', '', '')
endf


" s:log({lvl:string}, {fmt:string}, [{expr1:any}, ...]) -> 0
" Log a {message} with level {lvl}. Arguments behave like printf.
func s:log(lvl, fmt, ...)
	let time = strftime('%T', reltimestr(reltime()))
	let message = call('printf', [a:fmt] + a:000)
	let entry = {'timestamp': time, 'lvl': a:lvl, 'message': message}
	call add(s:logs,  entry)
endf


" s:id() -> number
" Return a new unique id.
func s:id()
	return localtime()
endf


" s:err({fmt:string}, [{expr1:any}, ...]) -> 0
" Display an error message. Arguments behave like printf.
func! s:err(fmt, ...)
	echohl WarningMsg | echom call('printf', [a:fmt] + a:000)  | echohl None
endf
