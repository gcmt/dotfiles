

let s:default_actions = {
	\ 'ctrl-t': 'tab split',
	\ 'ctrl-s': 'split',
	\ 'ctrl-v': 'vsplit',
\ }

func! fzf#lines()

	func! s:lines__cb() dict
		if self.status == 1
			return s:err('Fzf failed')
		end
		if empty(self.selection)
			return
		end
		let [bufnr, bufname, linenr] = split(self.selection[0])[0:2]
		sil exec get(s:default_actions, self.key, '')
		exec 'buffer' bufnr
		exec linenr
		norm! zz
	endf

	let Fn = {i, nr -> buflisted(nr) && empty(getbufvar(nr, '&bt'))}
	let buffers = filter(range(1, bufnr('$')), Fn)

	let tails = {}
	for bufnr in buffers
		let tail = fnamemodify(bufname(bufnr), ':t')
		let tails[tail] = get(tails, tail) + 1
	endfo

	let padding = 0
	let bufnames = {}
	for bufnr in buffers
		let tail = fnamemodify(bufname(bufnr), ':t')
		if get(tails, tail) > 1
			let path = fnamemodify(bufname(bufnr), ':p')
			let tail = join(split(path, '/')[-2:], '/')
		end
		let bufnames[bufnr] = tail
		if len(tail) > padding
			let padding = len(tail)
		end
	endfor

	let lines = []
	for bufnr in buffers
		for [i, line] in map(getbufline(bufnr, 1, '$'), {i, v -> [i+1, v]})
			if !empty(line)
				call add(lines, printf("%s %".(padding)."s %4s  %s", bufnr, bufnames[bufnr], i, line))
			end
		endfor
	endfor

	let fzf_opts = [
		\ '--tac',
		\ '--tabstop', &ts,
		\ '--expect', join(keys(s:default_actions), ','),
		\ '--delimiter', ' ',
		\ '--with-nth', '2,3,4..-1',
		\ '--nth', '1,3..-1'
	\ ]

	call s:run({
		\ 'source': lines,
		\ 'callback': funcref('s:lines__cb'),
		\ 'fzf_opts': fzf_opts,
	\ })

endf

func! fzf#files(cwd)

	func! s:files__cb() dict
		if self.status == 1
			return s:err('Fzf failed')
		end
		if empty(self.selection)
			return
		end
		if !empty(self.cwd)
			call map(self.selection, {i, v -> s:joinpaths(self.cwd, v)})
		end
		if len(self.selection) > 1
			exec 'argadd' join(self.selection)
		end
		sil exec get(s:default_actions, self.key, '')
		exec 'edit' fnameescape(self.selection[0])
	endf

	let fzf_opts = ['--multi', "--expect", join(keys(s:default_actions), ',')]

	if &columns >= 150
		let fzf_opts += ["--preview", 'head -100 {}']
	end

	call s:run({
		\ 'source': 'rg --files',
		\ 'callback': funcref('s:files__cb'),
		\ 'fzf_opts': fzf_opts,
		\ 'cwd' : empty(a:cwd) ? getcwd() : a:cwd,
	\ })

endf


func! s:default_opts()

	func! s:default_callback() dict
		if self.status
			return s:err('Fzf exited with status ' . self.status)
		end
	endf

	return {
		\ 'source': '',
		\ 'callback': funcref('s:default_callback'),
		\ 'fzf_opts': [],
		\ 'cwd': getcwd(),
	\ }

endf


func! s:default_fzf_opts()

	let opts = [
		\ "--color", "fg+:18,bg+:24,hl+:1,hl:1,prompt:-1,pointer:-1,info:23",
	\ ]

	return opts

endf


func! s:run(opts)

	let opts = extend(a:opts, s:default_opts(), 'keep')

	let fzf_opts = a:opts.fzf_opts + s:default_fzf_opts()

	let out_file = tempname()
	let in_file = tempname()

	let exit_cb_ctx = {
		\ 'callback': a:opts.callback,
		\ 'outfile': out_file,
		\ 'infile': in_file,
		\ 'curwin': winnr(),
		\ 'laststatus': &laststatus,
		\ 'cwd': a:opts.cwd,
		\ 'expect': 0,
	\ }

	for opt in fzf_opts
		if opt =~# '\v^--expect$'
			let exit_cb_ctx['expect'] = 1
			break
		end
	endfo

	let job_opts = {
		\ 'cwd': a:opts.cwd,
		\ 'exit_cb': funcref('s:exit_cb', [], exit_cb_ctx),
		\ 'term_finish': 'close',
		\ 'term_kill': 'term',
		\ 'out_io': 'file',
		\ 'out_name': out_file,
	\ }

	let $FZF_DEFAULT_OPTS = ''
	let $FZF_DEFAULT_COMMAND = ''

	if type(a:opts.source) == v:t_string
		let $FZF_DEFAULT_COMMAND = a:opts.source
	elseif type(a:opts.source) == v:t_list
		call writefile(a:opts.source, in_file, 's')
		let job_opts['in_io'] = 'file'
		let job_opts['in_name'] = in_file
	elseif type(a:opts.source) == v:t_func
		call writefile(a:opts.source(), in_file, 's')
		let job_opts['in_io'] = 'file'
		let job_opts['in_name'] = in_file
	else
		return s:err("invalid source: must be a string, list, or function: " . string(a:opts.source))
	end

	au TerminalOpen * ++once setl laststatus=0

	call map(fzf_opts, {i, v -> shellescape(v)})
	call term_start(['sh', '-c', join(['fzf'] + fzf_opts)], job_opts)

endf


func! s:exit_cb(job, status) dict

	let &laststatus = self.laststatus
	exec self.curwin . 'wincmd w'

	let selection = readfile(self.outfile)
	call delete(self.outfile)

	let ctx = {
		\ 'status': a:status,
		\ 'key': '',
		\ 'selection': [],
		\ 'cwd': self.cwd,
	\ }

	if self.expect
		let ctx['key'] = get(selection, 0, '')
		let ctx['selection'] = selection[1:]
	else
		let ctx['selection'] = selection
	end

	call funcref(self.callback, [], ctx)()

endf


func! s:joinpaths(...)
	let args = filter(copy(a:000), {-> !empty(v:val)})
	let path = substitute(join(args, '/'), '\v/+', '/', 'g')
	return substitute(path, '\v/+$', '', '')
endf


func! s:err(message)
	echohl WarningMsg | echom a:message | echohl None
endf
