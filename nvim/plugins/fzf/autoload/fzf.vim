
func! fzf#files(source, bang = v:false, cwd = "")
    let fzf_opts = g:fzf_options
    if !empty(g:fzf_expect) && type(g:fzf_expect) == v:t_dict
        let fzf_opts += ["--expect", join(keys(g:fzf_expect), ',')]
    end
    if &columns > g:fzf_preview_treshold
        let fzf_opts += ["--preview", g:fzf_preview_cmd]
    end
    let source = a:source
    if empty(source)
        if !a:bang
            let source = g:fzf_files_cmd
        else
            let source = empty(g:fzf_files_cmd_bang) ? g:fzf_files_cmd : g:fzf_files_cmd_bang
        end
    end
    call s:run({
        \ 'source': source,
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

    let $FZF_DEFAULT_OPTS = join(a:opts.fzf_opts)
    let $FZF_DEFAULT_COMMAND = a:opts.source

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
    let fzf_cmd = ['fzf'] + fzf_opts + ['>'.ctx.outfile]

    if !empty($TMUX)
        let env = "FZF_DEFAULT_COMMAND=" . shellescape($FZF_DEFAULT_COMMAND)
        let tmux_cmd = [g:fzf_tmux_cmd, '-e', env, '-d', shellescape(a:opts.cwd)]
        let cmd = join(tmux_cmd + [shellescape(join(fzf_cmd))])
    else
        let cmd = g:fzf_term_cmd . ' -e sh -c ' . shellescape(join(fzf_cmd))
    end

    sil call system(cmd, [])
    call call('s:handle_selection', [v:shell_error], ctx)
endf

func! s:handle_selection(status) dict

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
    echohl WarningMsg | echom call('printf', ['fzf: ' . a:fmt] + a:000)  | echohl None
endf
