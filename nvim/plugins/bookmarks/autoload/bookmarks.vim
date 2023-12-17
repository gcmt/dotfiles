
let s:marks = {} " maps paths to marks
let s:bufname = '__bookmarks__'

" Load marks from file.
func s:load_marks()
    let file = expand(g:bookmarks_file)
    if !empty(file) && filereadable(file)
        let s:marks = json_decode(readfile(file))
    end
endf

" Write marks to file.
func s:write_marks()
    let file = expand(g:bookmarks_file)
    if !empty(file)
        call writefile([json_encode(s:marks)], file)
    end
endf

" Load bookmarks file and create the container directory if it does not exist
" yet
if !empty(expand(g:bookmarks_file))
    call mkdir(fnamemodify(expand(g:bookmarks_file), ':p:h'), 'p')
    call s:load_marks()
end

" Returns all bookmarks. If a directory path is given, only bookmarks
" for files uner that directory tree are returned.
func bookmarks#marks(cwd = '') abort
    if empty(a:cwd)
        return copy(s:marks)
    else
        return filter(copy(s:marks), {path -> path =~# '\V\^' . a:cwd . '\(/\|\$\)'  })
    end
endf

" Remove the bookmark for the given path.
func bookmarks#unset(path) abort
    try
        call remove(s:marks, a:path)
        call s:write_marks()
    catch /E716.*/
    endtry
endf

" Set a bookmark for the given path.
func bookmarks#set(mark, path) abort
    if type(a:path) != v:t_string
        call s:err("Invalid target")
        return 0
    end
    let mark = type(a:mark) == v:t_number ? nr2char(a:mark) : a:mark
    if mark == "\<esc>" || empty(mark)
        return 0
    end
    if !s:is_valid(mark)
        call s:err("Invalid mark")
        return 0
    end
    let s:marks[a:path] = a:mark
    call s:write_marks()
    let what = isdirectory(a:path) ? 'directory' : 'file'
    call s:echo(printf("%s \"%s\" marked with [%s]", what, s:prettify_path(a:path), mark))
    return 1
endf

" Jump to the file with the given mark. If a command is given, it is used to
" edit the file. One can jump to a bookmark only if it is under the current
" working directory.
func bookmarks#jump(mark, cmd = 'edit') abort
    let mark = type(a:mark) == v:t_number ? nr2char(a:mark) : a:mark
    if mark == "\<esc>" || empty(mark)
        return 0
    end
    if !s:is_valid(mark)
        call s:err("Invalid mark")
        return 0
    end
    for [path_, mark_] in items(bookmarks#marks(getcwd()))
        if mark == mark_
            if isdirectory(path_)
                exec substitute(g:bookmarks_explorer_cmd, '%f', fnameescape(path_), '')
            else
                exec a:cmd fnameescape(path_)
            end
            return 1
        end
    endfor
    call s:err("Mark not set")
    return 0
endf

" Utility function to open the bookmarks view in non-interactive mode.
func bookmarks#quickjump(all = 0) abort
    call bookmarks#view(a:all, 0)
endf

" Open a window or popup with all the bookmarks displayed. If the `all`
" parameter is given and it's 1, then all bookmarks are displayed, otherwise
" only bookmarks under the current working directory are displayed,
func bookmarks#view(all = 0, interactive = 1) abort

    let curr_bufpath = fnamemodify(bufname('%'), ':p')

    if bufwinnr(s:bufname) != -1
        return
    end

    " Retrieve all marks and sort them alphabetically
    let marks = bookmarks#marks(a:all ? '' : getcwd())

    let width = s:calculate_width()
    let height = s:calculate_height(len(marks))

    if g:bookmarks_popup && has('nvim')

        let bufnr = bufnr(s:bufname)
        if bufnr == -1
            let bufnr = nvim_create_buf(0, 0)
            call nvim_buf_set_name(bufnr, s:bufname)
        end

        let opts = {
            \ 'relative': 'editor',
            \ 'width': width,
            \ 'height': height,
            \ 'col': (&columns/2) - (width/2),
            \ 'row': float2nr(((&lines-2)/2) - (height/2)) - 1,
            \ 'anchor': 'NW',
            \ 'style': 'minimal',
            \ 'border': g:bookmarks_popup_borders,
        \ }

        let winid = nvim_open_win(bufnr, 1, opts)
        let winnr = bufwinnr(bufnr)

    else

        exec 'sil keepj keepa botright' height.'new' s:bufname
        let winnr = bufwinnr(s:bufname)
        let winid = win_getid(winnr)
        let bufnr = bufnr(s:bufname, 1)
        call bufload(bufnr)

        " hide statusbar
        exec 'au BufHidden <buffer='.bufnr.'> let &ls =' getwinvar(winnr, "&laststatus")
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

    let table = s:render(bufnr, marks)
    call setbufvar(bufnr, 'bookmarks_table', table)
    call setbufvar(bufnr, 'bookmarks_show_all', a:all)

    call cursor(1, 2)
    " position the cursor on the current file
    for [linenr, item] in items(b:bookmarks_table)
        if curr_bufpath == item[0]
            call cursor(linenr, 2)
        end
    endfor

    redraw

    if a:interactive
        call s:setup_mappings()
    else
        echo "Mark "
        while 1
            redraw
            try
                let mark = getcharstr()
            catch /^Vim:Interrupt$/
                " catches ctrl-c
                call s:action_close()
                break
            endtry
            if mark == "\<esc>" || empty(mark)
                call s:action_close()
                break
            end
            if !s:is_valid(mark)
                call s:err("Invalid mark")
                continue
            end
            if index(values(marks), mark) == -1
                call s:err("Unknown mark")
                continue
            end
            call s:action_close()
            call bookmarks#jump(mark)
            break
        endw
    end

    norm! "\<c-l>"

endf

" Setup all mappings in the current window
func s:setup_mappings() abort
    for key in g:bookmarks_mappings_jump
        exec "nnoremap <silent> <nowait> <buffer>" key ":call <sid>action_jump('edit')<cr>zz"
    endfor
    for key in g:bookmarks_mappings_unset
        exec "nnoremap <silent> <nowait> <buffer>" key ":call <sid>action_unset()<cr>"
    endfor
    for key in g:bookmarks_mappings_change
        exec "nnoremap <silent> <nowait> <buffer>" key ":call <sid>action_change()<cr>"
    endfor
    for key in g:bookmarks_mappings_close
        exec "nnoremap <silent> <nowait> <buffer>" key ":call <sid>action_close()<cr>"
    endfor
    for key in g:bookmarks_mappings_toggle_global
        exec "nnoremap <silent> <nowait> <buffer>" key ":call <sid>action_toggle_global_bookmarks()<cr>"
    endfor
endf

" Display bookmarks in the given buffer. If
" If the `all` parameter is given and it's 1, then all bookmarks are displayed,
" otherwise only bookmarks under the current working directory are displayed.
func s:render(bufnr, marks) abort

    let winid = bufwinid(a:bufnr)
    let pos_save = getpos('.')

    call clearmatches(winid)
    call setbufvar(a:bufnr, "&modifiable", 1)
    sil! call deletebufline(a:bufnr, 1, "$")

    " sort marks alphabetically
    let marks = sort(map(items(a:marks), {_, v -> [v[1], v[0]]}), 'l')

    " Create counter of files that share the same name
    let fnames = {}
    for [_, path] in marks
        let fname = fnamemodify(path, ':t')
        let fnames[fname] = get(fnames, fname, 0) + 1
    endfo

    let i = 1
    let table = {}
    for [mark, path] in marks

        let table[i] = [path, mark]

        let pattern = '\v%' . i . 'l%' . (2) . 'c.'
        call matchadd(g:bookmarks_hl_mark, pattern, -1, -1, #{window: winid})
        let line = '[' . mark . '] '

        let fname =  fnamemodify(path, ':t')
        if get(fnames, fname) > 1
            " for files that share the same name, also display container
            " directory
            let fname = join(split(path, '/')[-2:], '/')
        end
        let group = isdirectory(path) ? g:bookmarks_hl_dir : g:bookmarks_hl_file
        let pattern = '\v%' . i . 'l%>' . (len(line)) . 'c.*%<' . (len(line)+len(fname)+2) . 'c'
        call matchadd(group, pattern, -1, -1, #{window: winid})
        let line .= fname

        let path = s:prettify_path(path)
        let pattern = '\v%' . i . 'l%>' . (len(line)) . 'c.*'
        call matchadd(g:bookmarks_hl_dim, pattern, -1, -1, #{window: winid})
        let line .= ' ' . path

        call setbufline(a:bufnr, i, line)
        let i += 1

    endfor

    if empty(marks)
        call setbufline(a:bufnr, 1, " No bookmarks")
    end

    call matchadd(g:bookmarks_hl_dim, '\v(\[|\])', -1, -1, #{window: winid})

    let height = s:calculate_height(i-1)
    call win_execute(winid, 'resize '.height, 1)

    call setpos('.', pos_save)
    call setbufvar(a:bufnr, "&modifiable", 0)

    return table
endf

" Jump to the bookmark under cursor
func s:action_jump(cmd) abort
    let selected = get(b:bookmarks_table, line('.'), [])
    if empty(selected)
        return
    end
    call s:action_close()
    let path = selected[0]
    if isdirectory(path)
        exec substitute(g:bookmarks_explorer_cmd, '%f', fnameescape(path), '')
    else
        exec a:cmd fnameescape(path)
    end
endf

" Unset bookmark under cursor
func s:action_unset() abort
    let selected = get(b:bookmarks_table, line('.'), [])
    if empty(selected)
        return
    end
    call bookmarks#unset(selected[0])
    let cwd = b:bookmarks_show_all ? '' : getcwd()
    let b:bookmarks_table = s:render(bufnr('%'), bookmarks#marks(cwd))
endf

" Change letter for the bookmark under cursor
func s:action_change() abort
    let selected = get(b:bookmarks_table, line('.'), [])
    if empty(selected)
        return
    end
    let mark = input("New mark: ")
    if empty(mark)
        return
    end
    if !s:is_valid(mark)
        return s:err("Invalid mark")
    end
    call bookmarks#set(mark, selected[0])
    let cwd = b:bookmarks_show_all ? '' : getcwd()
    let b:bookmarks_table = s:render(bufnr('%'), bookmarks#marks(cwd))
endf

" Close bookmarks window
func s:action_close() abort
    call win_execute(bufwinid(s:bufname), 'close', 1)
endf

" Toggle visibility of global bookmarks
func s:action_toggle_global_bookmarks() abort
    let selected = get(b:bookmarks_table, line('.'), [])
    if empty(selected)
        return
    end
    let b:bookmarks_show_all = !b:bookmarks_show_all
    let cwd = b:bookmarks_show_all ? '' : getcwd()
    let b:bookmarks_table = s:render(bufnr('%'), bookmarks#marks(cwd))
    " keep cursor on the current mark
    for [linenr, mark] in items(b:bookmarks_table)
        if selected[0] == mark[0]
            call cursor(linenr, 2)
            break
        end
    endfor
endf

" Check if a mark is valid.
func s:is_valid(mark) abort
    if index(split(g:bookmarks_marks, '\zs'), a:mark) == -1
        return 0
    end
    return 1
endf

" calculate the width of the popup
func s:calculate_width() abort
    let percent = str2nr(trim(g:bookmarks_width_popup, '%'))
    return float2nr(&columns * percent / 100)
endf

" calculate the height of the popup or window
func s:calculate_height(content_length) abort
    let percent = str2nr(trim(g:bookmarks_height_popup, '%'))
    let max_height = float2nr((&lines-2) * percent / 100)
    return min([max_height, max([1, a:content_length])])
endf

" Prettify a path by stripping the working directory and substituting ~ to home
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
