
let s:marks = {}
let s:bufname = '__bookmarks__'

func bookmarks#marks()
    return s:marks
endf

func bookmarks#unset(mark)
    call remove(s:marks, a:mark)
endf

func bookmarks#set(mark, target) abort
    if type(a:target) != v:t_string
        return s:err("Invalid target")
    end
    let mark = type(a:mark) == v:t_number ? nr2char(a:mark) : a:mark
    if mark == "\<esc>"
        return
    end
    if len(mark) != 1 || g:bookmarks_marks !~# mark
        return s:err("Invalid mark")
    end
    if index(values(s:marks), a:target) > -1
        " dont allow multiple marks for the same target
        let i = index(values(s:marks), a:target)
        call remove(s:marks, keys(s:marks)[i])
    end
    let s:marks[mark] = a:target
    echo printf("file \"%s\" marked with [%s]", s:prettify_path(a:target), mark)
endf

func bookmarks#jump(mark, ...) abort
    let cmd = a:0 ? a:1 : 'edit'
    let mark = type(a:mark) == v:t_number ? nr2char(a:mark) : a:mark
    if mark == "\<esc>"
        return
    end
    if len(mark) != 1 || g:bookmarks_marks !~# mark
        return s:err("Invalid mark")
    end
    let target = get(s:marks, mark, '')
    if empty(target)
        return s:err("Mark not set")
    end
    if isdirectory(target)
        exec g:bookmarks_explorer_cmd fnameescape(target)
    else
        exec 'edit' fnameescape(s:prettify_path(target))
    end
endf

func bookmarks#view() abort

    if bufwinnr(s:bufname) != -1
        return
    end

    if empty(s:marks)
        return s:err("No bookmarks found")
    end

    exec 'sil keepj keepa botright 1new' s:bufname

    let winnr = bufwinnr(s:bufname)
    call setwinvar(winnr, '&cursorline', g:buffers_cursorline)
    call setwinvar(winnr, '&cursorcolumn', 0)
    call setwinvar(winnr, '&colorcolumn', 0)
    call setwinvar(winnr, '&signcolumn', "no")
    call setwinvar(winnr, '&wrap', 0)
    call setwinvar(winnr, '&number', 0)
    call setwinvar(winnr, '&relativenumber', 0)
    call setwinvar(winnr, '&list', 0)
    call setwinvar(winnr, '&textwidth', 0)
    call setwinvar(winnr, '&undofile', 0)
    call setwinvar(winnr, '&backup', 0)
    call setwinvar(winnr, '&swapfile', 0)
    call setwinvar(winnr, '&spell', 0)

    " wipe any message
    echo

    let bufnr = bufnr(s:bufname, 1)
    call bufload(bufnr)

    call setbufvar(bufnr, '&filetype', 'bookmarks')
    call setbufvar(bufnr, '&buftype', 'nofile')
    call setbufvar(bufnr, '&bufhidden', 'hide')
    call setbufvar(bufnr, '&buflisted', 0)
    call setbufvar(bufnr, 'bookmarks', {'table': {}})

    " hide statusbar
    exec 'au BufHidden <buffer='.bufnr.'> let &laststatus = ' getwinvar(winnr, "&laststatus")
    call setwinvar(winnr, '&laststatus', '0')

    call bookmarks#render()
    call cursor(1, 2)

endf

func bookmarks#render()

    if &filetype != 'bookmarks'
        throw "Bookmarks: not allowed here"
    end

    syntax clear
    setl modifiable
    let pos_save = getpos('.')
    sil %delete _

    syn match BookmarksDim /\v(\[|\])/

    let i = 1
    let b:bookmarks.table = {}
    for [mark, target] in sort(items(s:marks))

        let b:bookmarks.table[i] = mark

        exec 'syn match BookmarksMark /\v%'.i.'l%'.(2).'c./'
        let line = '['.mark.'] '

        let tail = fnamemodify(target, ':t')
        let group = isdirectory(target) ? 'BookmarksDir' : 'BookmarksFile'
        exec 'syn match '.group.' /\v%'.i.'l%>'.(len(line)).'c.*%<'.(len(line)+len(tail)+2).'c/'
        let line .= tail

        let target = s:prettify_path(target)
        exec 'syn match BookmarksDim /\v%'.i.'l%>'.(len(line)).'c.*/'
        let line .= ' ' . target

        call setline(i, line)
        let i += 1

    endfor

    call s:resize_window(line('$'))
    call setpos('.', pos_save)
    setl nomodifiable

endf

func s:resize_window(entries_num)
    let max = float2nr(&lines * g:bookmarks_max_winsize / 100)
    exec 'resize' min([a:entries_num, max])
endf

func s:prettify_path(path)
    let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
    return substitute(path, '\V\^'.$HOME, '~', '')
endf

func s:err(msg)
    echohl WarningMsg | echo a:msg | echohl None
endf
