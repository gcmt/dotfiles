
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
    call s:echo(printf("file \"%s\" marked with [%s]", s:prettify_path(a:target), mark))
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

    let curr_buf = fnamemodify(bufname('%'), ':p')

    if g:bookmarks_popup

        let bufnr = nvim_create_buf(0, 0)
        let ui = nvim_list_uis()[0]

        let percent = ui.width < 120 ? 80 : 60
        let width = float2nr(ui.width * percent / 100)
        let height = 10

        let opts = {
            \ 'relative': 'editor',
            \ 'width': width,
            \ 'height': height,
            \ 'col': (ui.width/2) - (width/2),
            \ 'row': (ui.height/2) - (height/2),
            \ 'anchor': 'NW',
            \ 'style': 'minimal',
            \ 'border': g:bookmarks_popup_borders,
        \ }

        let winid = nvim_open_win(bufnr, 1, opts)
        let winnr = bufwinnr(bufnr)

    else

        exec 'sil keepj keepa botright 1new' s:bufname
        let winnr = bufwinnr(s:bufname)
        let winid = win_getid(winnr)
        let bufnr = bufnr(s:bufname, 1)
        call bufload(bufnr)

        " hide statusbar
        exec 'au BufHidden <buffer='.bufnr.'> let &laststatus = ' getwinvar(winnr, "&laststatus")
        call setwinvar(winnr, '&laststatus', '0')

    end

    call setwinvar(winnr, '&cursorline', g:bookmarks_cursorline)
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

    call setbufvar(bufnr, '&filetype', 'bookmarks')
    call setbufvar(bufnr, '&buftype', 'nofile')
    call setbufvar(bufnr, '&bufhidden', 'hide')
    call setbufvar(bufnr, '&buflisted', 0)
    call setbufvar(bufnr, 'bookmarks', {'table': {}})

    call bookmarks#render()
    call cursor(1, 2)

    " position the cursor on the current file
    for [linenr, mark] in items(b:bookmarks.table)
        if curr_buf == get(s:marks, mark, '')
            call cursor(linenr, 2)
        end
    endfor

    " wipe any message
    echo

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
    let max = float2nr(&lines * g:bookmarks_max_height / 100)
    exec 'resize' min([a:entries_num, max])
endf

func s:prettify_path(path)
    let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
    return substitute(path, '\V\^'.$HOME, '~', '')
endf

func s:err(msg)
    norm! "\<c-l>"
    echohl WarningMsg | echo a:msg | echohl None
endf

func s:echo(msg)
    norm! "\<c-l>"
    echo a:msg
endf

