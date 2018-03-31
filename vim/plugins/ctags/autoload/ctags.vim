
let s:queue = []
let s:status = 'idle'

func ctags#status()
	return s:status
endf

func s:err(msg)
	echohl WarningMsg | echom a:msg | echohl None
endf

func s:cmd(args)
	let options = get(g:, 'ctags_'.&ft.'_options', '')
	return ['ctags', '-Rn', options] + split(a:args)
endf

func ctags#sync(args) abort
	if s:status == 'busy'
		return s:err("Currently busy building tags")
	end
	let out = system(join(s:cmd(a:args)))
	if v:shell_error
		let s:status = 'error'
		return s:err(out)
	end
	let s:status = 'ready'
	doau User UpdateTagfiles
	echom "Tags successfully generated"
endf

func ctags#async(args) abort
	if s:status == 'busy'
		let s:queues = [a:args]
		return
	end
	let s:status = 'busy'
	call job_start(s:cmd(a:args), {
		\ 'exit_cb': 'ctags#exit_handler'
	\ })
endf

func ctags#exit_handler(job, status)
	let s:status = 'ready'
	if a:status != 0
		let s:status = 'error'
		call s:err("Failed to generate tags (exit status " . a:status . ")")
	end
	doau User UpdateTagfiles
	if !empty(s:queue)
		call ctags#async(remove(s:queue, -1))
	end
endf
