
let s:marks = {}
let s:bufname = '__bookmarks__'
let s:bookmarks_file = expand(g:bookmarks_file)

func! s:load_marks()
    if !empty(s:bookmarks_file) && filereadable(s:bookmarks_file)
        let s:marks = json_decode(readfile(s:bookmarks_file))
    end
endf

func! s:write_marks()
    if !empty(s:bookmarks_file)
        call writefile([json_encode(s:marks)], s:bookmarks_file)
    end
endf

call mkdir(fnamemodify(s:bookmarks_file, ':p:h'), 'p')
call s:load_marks()

func bookmarks#marks(cwd = '') abort
    if empty(a:cwd)
        return copy(s:marks)
    else
        " Return only marks for files inside the current cwd
        return filter(copy(s:marks), {path -> path =~# '\V\^' . a:cwd . '\(/\|\$\)'  })
    end
endf

func bookmarks#unset(path) abort
    try
        call remove(s:marks, a:path)
        call s:write_marks()
    catch /E716.*/
    endtry
endf

func bookmarks#set(mark, path) abort
    if type(a:path) != v:t_string
        return s:err("Invalid target")
    end
    let mark = type(a:mark) == v:t_number ? nr2char(a:mark) : a:mark
    if mark == "\<esc>"
        return
    end
    if len(mark) != 1 || g:bookmarks_marks !~# mark
        return s:err("Invalid mark")
    end
    let s:marks[a:path] = a:mark
    call s:write_marks()
    call s:echo(printf("file \"%s\" marked with [%s]", s:prettify_path(a:path), mark))
endf

" TODO: check for multiple matches
func bookmarks#jump(mark, ...) abort
    let mark = type(a:mark) == v:t_number ? nr2char(a:mark) : a:mark
    if mark == "\<esc>"
        return
    end
    if len(mark) != 1 || g:bookmarks_marks !~# mark
        return s:err("Invalid mark")
    end
    let path = ''
    for [p, m] in items(bookmarks#marks(getcwd()))
        if m == a:mark
            let path = p
            break
        end
    endfor
    if empty(path)
        return s:err("Mark not set")
    end
    if isdirectory(path)
        exec substitute(g:bookmarks_explorer_cmd, '%f', fnameescape(path), '')
    else
        let cmd = a:0 ? a:1 : 'edit'
        exec cmd fnameescape(s:prettify_path(path))
    end
endf

func bookmarks#view(all = 0) abort

    if bufwinnr(s:bufname) != -1
        return
    end

    let cwd = a:all ? '' : getcwd()
    if empty(bookmarks#marks(cwd))
        return s:err("No bookmarks found")
    end

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

    call s:setup_mappings()
    call s:render(bufnr, a:all)
    call cursor(1, 2)

    " position the cursor on the current file
    let current = fnamemodify(bufname('%'), ':p')
    for [linenr, item] in items(b:bookmarks.table)
        if current == item[0]
            call cursor(linenr, 2)
        end
    endfor

    " wipe any message
    echo

endf

func s:setup_mappings() abort
    for key in g:bookmarks_mappings_jump
        exec "nnoremap <silent> <nowait> <buffer>" key ":call <sid>action_jump('edit')<cr>zz"
    endfor
    for key in g:bookmarks_mappings_unset
        exec "nnoremap <silent> <nowait> <buffer>" key ":call <sid>action_unset()<cr>"
    endfor
    for key in g:bookmarks_mappings_close
        exec "nnoremap <silent> <nowait> <buffer>" key ":close<cr>"
    endfor
    for key in g:bookmarks_mappings_toggle_global
        exec "nnoremap <silent> <nowait> <buffer>" key ":call <sid>action_toggle_global_bookmarks()<cr>"
    endfor
endf

func s:render(bufnr, all = 0) abort

    syntax clear
    setl modifiable
    let pos_save = getpos('.')
    sil %delete _

    syn match BookmarksDim /\v(\[|\])/

    let b:show_all = get(b:, 'show_all', a:all)
    let cwd = b:show_all ? '' : getcwd()

    let i = 1
    let b:bookmarks.table = {}
    let marks = sort(map(items(bookmarks#marks(cwd)), {_, v -> [v[1], v[0]]}), 'l')
    for [mark, path] in marks

        let b:bookmarks.table[i] = [path, mark]

        exec 'syn match BookmarksMark /\v%'.i.'l%'.(2).'c./'
        let line = '['.mark.'] '

        let tail = fnamemodify(path, ':t')
        let group = isdirectory(path) ? 'BookmarksDir' : 'BookmarksFile'
        exec 'syn match '.group.' /\v%'.i.'l%>'.(len(line)).'c.*%<'.(len(line)+len(tail)+2).'c/'
        let line .= tail

        let path = s:prettify_path(path)
        exec 'syn match BookmarksDim /\v%'.i.'l%>'.(len(line)).'c.*/'
        let line .= ' ' . path

        call setbufline(a:bufnr, i, line)
        let i += 1

    endfor

    if empty(marks)
        call setbufline(a:bufnr, 1, " No bookmarks")
    end

    call s:resize_window(line('$'))
    call setpos('.', pos_save)
    setl nomodifiable

endf

func s:action_jump(cmd) abort
    let win = winnr()
    let selected = get(b:bookmarks.table, line('.'), [])
    if !empty(selected)
        close
        let path = selected[0]
        if isdirectory(path)
            exec substitute(g:bookmarks_explorer_cmd, '%f', fnameescape(path), '')
        else
            exec a:cmd fnameescape(s:prettify_path(path))
        end
    end
endf

func s:action_unset() abort
    let selected = get(b:bookmarks.table, line('.'), [])
    if !empty(selected)
        call bookmarks#unset(selected[0])
        call s:render(bufnr('%'))
    end
endf

func s:action_toggle_global_bookmarks() abort
    let current = get(b:bookmarks.table, line('.'), [])
    let b:show_all = !b:show_all
    call s:render(bufnr('%'))
    if !empty(current)
        " keep cursor on current mark
        for [linenr, mark] in items(b:bookmarks.table)
            if current[0] == mark[0]
                call cursor(linenr, 2)
                break
            end
        endfor
    end
endf

func s:resize_window(entries_num) abort
    let max = float2nr(&lines * g:bookmarks_max_height / 100)
    exec 'resize' min([a:entries_num, max])
endf

func s:prettify_path(path) abort
    let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
    return substitute(path, '\V\^'.$HOME, '~', '')
endf

func s:err(msg) abort
    redraw | echohl WarningMsg | echo a:msg | echohl None
endf

func s:echo(msg) abort
    redraw | echo a:msg
endf
