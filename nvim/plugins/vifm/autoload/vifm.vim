
" Open the given file/directory
func! vifm#open(target, bang)

    let out_file = tempname()

    let cmd  = ['vifm']
    let cmd += ['--choose-files='.out_file]
    if filereadable(a:target)
        let cmd += ['--select='.shellescape(a:target)]
    else
        let cmd += [fnamemodify(a:target, ':p:h')]
    end
    if !empty(a:bang)
        let cmd += ["+fzf"]
    end

    let Callback = funcref('s:vifm_callback')

    let exit_cb_ctx = {
        \ 'cmd': cmd,
        \ 'callback': Callback,
        \ 'out_file': out_file,
        \ 'curwin': winnr(),
    \ }

    if !empty($TMUX)
        let cmd = join([g:fm_tmux_cmd] + cmd)
    else
        let cmd = join([g:fm_term_cmd] + ['-e'] + cmd)
    end

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

" s:err({fmt:string}, [{expr1:any}, ...]) -> 0
" Display a error message.
func! s:err(fmt, ...)
    echohl WarningMsg | echom call('printf', [a:fmt] + a:000)  | echohl None
endf
