
let s:actions = {
	\ 'ctrl-t': 'tab split',
	\ 'ctrl-s': 'split',
	\ 'ctrl-v': 'vsplit',
\ }

func! fzf#search_files(cwd)
	let tmp_file = tempname()
	let exit_cb_ctx = {
		\ 'outfile': tmp_file,
		\ 'curwin': winnr(),
		\ 'cwd': a:cwd,
	\ }
	let job_opts = {
		\ 'exit_cb': funcref('s:exit_cb', [], exit_cb_ctx),
		\ 'term_finish': 'close',
		\ 'term_kill': 'term',
	\ }
	if !empty(a:cwd)
		let job_opts['cwd'] = a:cwd
	end
	let fzf_opts = ["--multi"]
	call add(fzf_opts, "--expect=" . join(keys(s:actions), ','))
	call add(fzf_opts, "--color fg+:18,bg+:24,hl+:1,hl:1,prompt:-1,pointer:-1,info:23")
	if &columns >= g:fzf_preview_treshold
		call add(fzf_opts, "--preview '".g:fzf_preview_cmd."'")
	end
	let cmd = 'fzf ' . join(fzf_opts) . ' >'.tmp_file
	if executable('rg')
		let cmd = 'rg --files | ' . cmd
	end
	call term_start(['sh', '-c', cmd], job_opts)
endf

func! s:exit_cb(job, status) dict
	if a:status == 1
		return s:err('Fzf failed')
	end
	exec self.curwin . 'wincmd w'
	let selection = readfile(self.outfile)
	if empty(selection)
		return
	end
	let key = selection[0]
	let files = selection[1:]
	if !empty(self.cwd)
		let files = map(files, {i, v -> s:joinpaths(self.cwd, v)})
	end
	if len(files) > 1
		exec 'argadd' join(files)
	end
	sil exec get(s:actions, key, '')
	exec 'edit' fnameescape(files[0])
	call delete(self.outfile)
endf

func! s:joinpaths(...)
	let args = filter(copy(a:000), {-> !empty(v:val)})
	let path = substitute(join(args, '/'), '\v/+', '/', 'g')
	return substitute(path, '\v/+$', '', '')
endf

func! s:err(message)
	echohl WarningMsg | echom a:message | echohl None
endf
