
" Open the given file/directory
" When using a bang, vifm will be started in fzf mode
func! vifm#open(target, bang)

    let curwin = winnr()
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

    if !empty($TMUX)
        let cmd = join([g:fm_tmux_cmd] + cmd)
    else
        let cmd = join([g:fm_term_cmd] + ['-e'] + cmd)
    end

    sil call system(cmd)
    if v:shell_error != 0 || !filereadable(out_file)
        return
    end

    exec curwin . 'wincmd w'
    call s:handle_selection(readfile(out_file))
    call delete(out_file)
endf

" Handle files selection
func! s:handle_selection(lines)
    if empty(a:lines)
        return
    end
    call map(a:lines, {i, v -> fnameescape(v)})
    if len(a:lines) > 1
        exec 'argadd' join(a:lines)
    end
    if expand('%:p') != a:lines[0]
        " Otherwise autocommands don't get fired
        exec 'edit' a:lines[0]
    end
    redraw!
endf

" Display a error message.
func! s:err(fmt, ...)
    echohl WarningMsg | echom call('printf', [a:fmt] + a:000)  | echohl None
endf
