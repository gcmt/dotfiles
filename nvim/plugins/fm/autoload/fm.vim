
" Open the given file/directory
func! fm#open(target)

    let out_file = tempname()

    if g:fm_cmd == 'vifm'

        let cmd  = ['vifm']
        let cmd += ['--choose-files='.out_file]

        if filereadable(a:target)
            let cmd += ['--select='.shellescape(a:target)]
        else
            let cmd += [fnamemodify(a:target, ':p:h')]
        end

        let Callback = funcref('s:vifm_callback')

    elseif g:fm_cmd == 'ranger'

        let cmd  = ['ranger']
        let cmd += ['--choosefiles='.out_file]
        let cmd += s:ranger_bindings()

        if &columns < g:fm_preview_treshold
            let cmd += [
                \ "--cmd='set column_ratios 1'",
                \ "--cmd='set preview_files false'",
                \ "--cmd='set preview_directories false'",
                \ "--cmd='set collapse_preview true'",
            \ ]
        end

        if filereadable(a:target)
            let cmd += ['--selectfile='.shellescape(a:target)]
        else
            let cmd += [fnamemodify(a:target, ':p:h')]
        end

        let Callback = funcref('s:ranger_callback')

    else
        return s:err("Invalid file manager: " . a:fn)
    end

    let exit_cb_ctx = {
        \ 'cmd': cmd,
        \ 'callback': Callback,
        \ 'out_file': out_file,
        \ 'curwin': winnr(),
    \ }

    let cmd = join([g:fm_term_prg] + ['-e'] + cmd)
    sil call system(cmd)
    call call('s:exit_cb', [-1, v:shell_error], exit_cb_ctx)

endf


" s:exit_cb({job}, {status:int}) -> 0
" Read the output file and pass the file selection to the callback function.
func! s:exit_cb(job, status) dict
    exec self.curwin . 'wincmd w'
    if !filereadable(self.out_file)
        return
    end
    let lines = readfile(self.out_file)
    call delete(self.out_file)
    let ctx = {'status': a:status, 'selection': lines, 'cmd': self.cmd}
    call funcref(self.callback, [], ctx)()
endf


" s:vifm_callback() -> 0
func! s:vifm_callback() dict
    if empty(self.selection)
        return
    end
    call map(self.selection, {i, v -> fnameescape(v)})
    if len(self.selection) > 1
        exec 'argadd' join(self.selection)
    end
    if expand('%:p') != self.selection[0]
        " Otherwise autocommands don't get fired
        exec 'edit' self.selection[0]
    end
    redraw!
endf


" s:ranger_callback() -> 0
func! s:ranger_callback() dict
    if self.status
        return s:err("Command failed with error %d: %s", self.status, self.cmd)
    end
    if empty(self.selection)
        return
    end
    let mode = ''
    let selection = self.selection
    if get(selection, 0, '') =~ '\v^#meta'
        let mode = matchstr(selection[0], '\v<mode\=\zs\w+')
        call remove(selection, 0)
    end
    call map(selection, {i, v -> fnameescape(v)})
    if len(selection) > 1
        exec 'argadd' join(selection)
    end
    let commands = {
        \ 'window': '',
        \ 'tab': 'tab split',
        \ 'split': 'split',
        \ 'vsplit': 'vsplit',
    \ }
    sil exec get(commands, mode, '')
    exec 'edit' selection[0]
    redraw!
endf


" s:ranger_bindings() -> list
" Return custom ranger bindings.
func! s:ranger_bindings()
    let default_bindings = {
        \ 'l': 'window', 'ee': 'window',
        \ 'es': 'split', 'ev': 'vsplit',
        \ 'et': 'tab'
    \ }
    let bindings = []
    for [k, v] in items(default_bindings)
        call add(bindings, printf("--cmd='map %s choose mode=%s'", k, v))
    endfo
    return bindings
endf


" s:err({fmt:string}, [{expr1:any}, ...]) -> 0
" Display a error message.
func! s:err(fmt, ...)
    echohl WarningMsg | echom call('printf', [a:fmt] + a:000)  | echohl None
endf
