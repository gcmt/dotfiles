
let s:queue = []
let s:status = 'idle'

func tagmaker#status()
	return s:status
endf

func s:err(msg)
	echohl WarningMsg | echom a:msg | echohl None
endf

func s:cmd(args)
	return ['ctags', '-R'] + split(a:args)
endf

func tagmaker#sync(args) abort
	if s:status == 'busy'
		return s:err("Currently busy building tags")
	end
	let out = system(join(s:cmd(a:args)))
	if v:shell_error
		let s:status = 'error'
		return s:err(out)
	end
	let s:status = 'ready'
	doau User TagMakerPost
	echom "Tags successfully generated"
endf

func tagmaker#async(args) abort
	if s:status == 'busy'
		let s:queues = [a:args]
		return
	end
	let s:status = 'busy'
	call job_start(s:cmd(a:args), {
		\ 'exit_cb': 'tagmaker#exit_handler'
	\ })
endf

func tagmaker#exit_handler(job, status)
	let s:status = 'ready'
	if a:status != 0
		let s:status = 'error'
		call s:err("Failed to generate tags (exit status " . a:status . ")")
	end
	doau User TagMakerPost
	if !empty(s:queue)
		call tagmaker#async(remove(s:queue, -1))
	end
endf
