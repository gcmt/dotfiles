
let s:bufname = '__find__'

func find#findg(path, query) abort
    if empty(a:query) && !bufexists(s:bufname)
        return s:err('No previous searches')
    end
    let results = []
    if !empty(a:query)
        let cmd = printf('rg -l --sort-files %s %s', shellescape(a:query), shellescape(a:path))
        let results = systemlist(cmd)
        if v:shell_error
            if empty(results)
                return s:err("Nothing found")
            else
                return s:err(join(results, "\n"))
            end
        end
    end
    call s:view_results(results)
endf


func find#find(path, query, autojump = 0) abort
    if empty(a:query) && !bufexists(s:bufname)
        return s:err('No previous searches')
    end
    let results = []
    if !empty(a:query)
        let input = system('rg --files --sort-files ' . shellescape(a:path))
        let results = systemlist('rg ' . shellescape(a:query), input)
        if v:shell_error
            if empty(results)
                return s:err("Nothing found")
            else
                return s:err(join(results, "\n"))
            end
        end
    end
    if a:autojump && len(results) == 1
        let path = substitute(results[0], getcwd().'/', '', '')
        exec 'edit' fnameescape(path)
    else
        call s:view_results(results)
    end
endf

func s:view_results(results) abort
    if bufwinnr(s:bufname) != -1
        exec bufwinnr(s:bufname).'wincmd w'
    else
        exec 'sil keepj keepa botright 1new' s:bufname
        setl filetype=find buftype=nofile bufhidden=hide nobuflisted
        setl noundofile nobackup noswapfile nospell
        setl nowrap nonumber norelativenumber nolist textwidth=0
        setl cursorline nocursorcolumn colorcolumn=0
        call setwinvar(0, '&stl', ' find')
    end
    call s:render(a:results[:g:find_max_results])
endf

func s:render(files) abort

    if empty(a:files)
        let table = get(get(b:, 'find', {}), 'table', {})
        let files = map(sort(keys(table)), {-> b:find.table[v:val]})
    else
        let files = a:files
    end

    if empty(files)
        close
        return s:err("find: error: no files to render")
    end

    syntax clear
    setl modifiable
    let line_save = line('.')
    sil %delete _

    let tails = {}
    for path in files
        let tail = fnamemodify(path, ':t')
        let tails[tail] = get(tails, tail) + 1
    endfo

    let i = 1
    let b:find = { 'table': {}}
    for path in files

        let line = ''
        let b:find.table[i] = path
        let path = s:prettify_path(path)

        let tail = fnamemodify(path, ':t')
        if get(tails, tail) > 1
            let tail = join(split(path, '/')[-2:], '/')
        end
        let line .= tail

        if path != tail
            exec 'syn match FindDim /\%'.i.'l\%'.(len(line)+1).'c.*/'
            let line .= ' ' . path
        end

        call setline(i, line)
        let i += 1

    endfor

    setl nomodifiable
    call s:resize_window()
    norm! gg
    exec line_save

endf

" Resize the current window according to g:find_max_winsize.
" That value is expected to be expressed in percentage.
func s:resize_window()
    let max = float2nr(&lines * g:find_max_winsize / 100)
    exec 'resize' min([line('$'), max])
endf

func s:prettify_path(path)
    let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
    let path = substitute(path, '\V\^'.$HOME, '~', '')
    return path
endf

func s:err(msg)
    echohl WarningMsg | echo a:msg | echohl None
endf
