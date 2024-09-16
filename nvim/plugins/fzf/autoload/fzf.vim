
func! fzf#files(cwd, bang)
    let fzf_opts = g:fzf_options
    if !empty(g:fzf_expect) && type(g:fzf_expect) == v:t_dict
        let fzf_opts += ["--expect", join(keys(g:fzf_expect), ',')]
    end
    if &columns > g:fzf_preview_treshold
        let fzf_opts += ["--preview", g:fzf_preview_cmd]
    end
    call s:run({
        \ 'source': empty(a:bang) ? g:fzf_files_cmd : g:fzf_files_cmd_bang,
        \ 'callback': funcref('s:files__cb'),
        \ 'fzf_opts': fzf_opts,
        \ 'cwd' : empty(a:cwd) ? getcwd() : a:cwd,
    \ })
endf

func! s:files__cb() dict
    if self.status == 1
        return s:err('exited with status 1')
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
    sil exec get(g:fzf_expect, self.key, '')
    exec 'edit' fnameescape(self.selection[0])
endf

func! s:run(opts)

    let $FZF_DEFAULT_COMMAND = ''
    let $FZF_DEFAULT_OPTS = join(a:opts.fzf_opts)

    if type(a:opts.source) == v:t_func
        let a:opts.source = call(a:opts.source, [])
    end

    if type(a:opts.source) == v:t_string
        let $FZF_DEFAULT_COMMAND = a:opts.source
    end

    let ctx = {
        \ 'callback': a:opts.callback,
        \ 'outfile': tempname(),
        \ 'infile': tempname(),
        \ 'curwin': winnr(),
        \ 'cwd': a:opts.cwd,
        \ 'expect': !empty(g:fzf_expect),
        \ 'selection': [],
    \ }

    let fzf_opts = copy(a:opts.fzf_opts)
    call map(fzf_opts, {i, v -> shellescape(v)})
    let cmd = ['fzf'] + fzf_opts + ['>'.ctx.outfile]

    if !empty($TMUX)
        let cmd = join([g:fzf_tmux_cmd, '-d', shellescape(a:opts.cwd), shellescape(join(cmd))])
    else
        let cmd = g:fzf_term_cmd . ' -e sh -c ' . shellescape(join(cmd))
    end

    let input = type(a:opts.source) == v:t_list ? a:opts.source : []

    sil call system(cmd, input)
    call call('s:exit_cb', [v:shell_error], ctx)
endf

func! s:exit_cb(status) dict

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
    echohl WarningMsg | echom call('printf', ['fzf: ', a:fmt] + a:000)  | echohl None
endf
