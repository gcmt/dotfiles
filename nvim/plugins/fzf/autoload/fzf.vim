
let s:default_actions = {
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-s': 'split',
    \ 'ctrl-v': 'vsplit',
\ }


func! fzf#files(cwd, bang)

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

    if &columns > g:fzf_preview_treshold
        let fzf_opts += ["--preview", 'head -100 {}']
    end

    call s:run({
        \ 'source': empty(a:bang) ? g:fzf_files_cmd : g:fzf_files_cmd_bang,
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
    return [
        \ "--color", "fg+:18,bg+:24,hl+:1,hl:1,prompt:-1,pointer:-1,info:23",
    \ ]
endf


func! s:run(opts)

    let opts = extend(a:opts, s:default_opts(), 'keep')
    let fzf_opts = a:opts.fzf_opts + s:default_fzf_opts()

    let out_file = tempname()
    let in_file = tempname()

    let exit_cb_ctx = {
        \ 'callback': opts.callback,
        \ 'outfile': out_file,
        \ 'infile': in_file,
        \ 'curwin': winnr(),
        \ 'cwd': opts.cwd,
        \ 'expect': 0,
        \ 'selection': [],
    \ }

    for opt in fzf_opts
        if opt =~# '\v^--expect$'
            let exit_cb_ctx['expect'] = 1
            break
        end
    endfo

    let $FZF_DEFAULT_COMMAND = ''
    let $FZF_DEFAULT_OPTS = g:fzf_default_opts

    if type(opts.source) == v:t_func
        let opts.source = call(opts.source, [])
    end

    let t_source = type(opts.source)
    if t_source != v:t_string && t_source != v:t_list
        return s:err("invalid source: must be string or list: %s", opts.source)
    end

    if t_source == v:t_string
        let $FZF_DEFAULT_COMMAND = opts.source
    end

    let fzf_opts += ['--layout=reverse', ]

    call map(fzf_opts, {i, v -> shellescape(v)})
    let cmd = ['fzf'] + fzf_opts

    let cmd = g:fzf_term_prg . ' -e sh -c "' . join(cmd) . ' >'.out_file.'"'
    let input = t_source == v:t_list ? opts.source : []
    sil call system(cmd, input)
    call call('s:exit_cb', [-1, v:shell_error], exit_cb_ctx)
endf


func! s:exit_cb(job, status) dict

    exec self.curwin . 'wincmd w'

    if filereadable(self.outfile)
        let selection = readfile(self.outfile)
    else
        return s:err('no selection')
    end

    call delete(self.outfile)
    call delete(self.infile)

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


func! s:err(fmt, ...)
    echohl WarningMsg | echom call('printf', [a:fmt] + a:000)  | echohl None
endf
