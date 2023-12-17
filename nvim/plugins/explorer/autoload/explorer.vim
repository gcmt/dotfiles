
let s:node = {}
let s:bufname = "__explorer__"

func! explorer#open(target, bang) abort

    if bufname("%") == s:bufname
        return
    end

    let target = empty(a:target) ? bufname('%') : a:target
    let target = fnamemodify(target, ':p')
    let dir = isdirectory(target) ? target : fnamemodify(target, ':h')

    let tree = s:node.new(dir, 'dir')
    let bufnr = s:open_window()
    call setbufvar(bufnr, "explorer", #{tree: tree, bufnr: bufnr})

    call tree.explore()
    call tree.render()
    call cursor(1, 1)
    call s:goto_first_child(tree)

endf

" s.open_window() -> number
" Open search buffer window or popup and return the buffer number.
func! s:open_window() abort

    let lines = &lines - 2
    let columns = &columns - 2

    if has('nvim') && g:explorer_popup

        let bufnr = bufnr(s:bufname)
        if bufnr == -1
            let bufnr = nvim_create_buf(0, 0)
            call nvim_buf_set_name(bufnr, s:bufname)
        end

        if type(g:explorer_width_popup) == v:t_string
            let percent = str2nr(trim(g:explorer_width_popup, '%'))
            let width = float2nr(columns * percent / 100)
        else
            throw "Invalid type for option width_popup: " . g:explorer_width_popup
        end

        if type(g:explorer_height_popup) == v:t_string
            let percent = str2nr(trim(g:explorer_height_popup, '%'))
            let height = float2nr(lines * percent / 100)
        else
            throw "Invalid type for option height_popup: " . g:explorer_height_popup
        end

        let opts = {
            \ 'relative': 'editor',
            \ 'width': width,
            \ 'height': height,
            \ 'col': (columns/2) - (width/2),
            \ 'row': float2nr((lines/2) - (height/2)) - 1,
            \ 'anchor': 'NW',
            \ 'style': 'minimal',
            \ 'border': g:explorer_popup_borders,
        \ }

        call nvim_open_win(bufnr, 1, opts)
        let winnr = bufwinnr(bufnr)

    else

        exec 'sil keepj keepa botright 2new' s:bufname
        let bufnr = bufnr(s:bufname)
        let winnr = bufwinnr(bufnr)
        call bufload(bufnr)

        if type(g:explorer_height_window) == v:t_string
            let percent = str2nr(trim(g:explorer_height_window, '%'))
            exec "resize" float2nr(lines * percent / 100)
        else
            throw "Invalid type for option height_window: " . g:explorer_height_window
        end

    end

    call setwinvar(winnr, '&cursorline',1)
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

    call setbufvar(bufnr, '&filetype', s:bufname)
    call setbufvar(bufnr, '&buftype', 'nofile')
    call setbufvar(bufnr, '&bufhidden', 'hide')
    call setbufvar(bufnr, '&buflisted', 0)

    call s:setup_mappings()

    return bufnr
endf

" s:setup_mappings() -> 0
" Setup mappings
func! s:setup_mappings()
    for [action, triggers] in items(__explorer_mappings())
        for trigger in triggers
            exec 'nnoremap <silent> <nowait> <buffer>' trigger ':call <sid>action__'.action.'()<cr>'
        endfor
    endfor
endf

" s:node.new({path:string}, {type:string}[, {parent:dict}]) -> dict
" Create a new node for the given {path} with type {type}.
" An optional {parent} node might be given as well.
func s:node.new(path, type, ...)
    let node = copy(s:node)
    let node.path = a:path
    let node.type = a:type
    let node.content = []
    let node.parent = a:0 > 0 ? a:1 : {}
    return node
endf

" s:node.set_path({path:string}) -> 0
" Set path for the current node.
func s:node.set_path(path)
    let self.path = a:path
endf

" s:node.filename() -> string
" Return the file name of the current node.
func s:node.filename()
    return fnamemodify(self.path, ':t')
endf

" s:node.info() -> string
" Return node info as returned by 'ls -l'.
func s:node.info()
    let cmd = 'ls -ldh ' . shellescape(self.path)
    return system(cmd)
endf

" s:node.ls() -> list
" Return a list of all files inside the current node.
func s:node.ls()
    if !isdirectory(self.path)
        return []
    end
    let cmd = 'ls -1AH --group-directories-first ' . shellescape(self.path)
    return systemlist(cmd)
endf

" s:node.explore([{max_depth:number}]) -> 0
" Get recursively the directory content of the current node up to
" {max_depth} levels deep. When not given, {max_depth} defaults to 1.
" This is a destructive operation: all child nodes are wiped out first.
func s:node.explore(...)

    func! s:_explore(node, lvl, max_depth)
        if a:lvl > a:max_depth
            return
        end
        let files = a:node.ls()
        if v:shell_error
            return
        end
        let a:node.content = []
        for fname in files
            let path = s:path_join(a:node.path, fname)
            let node = s:node.new(path, getftype(path), a:node)
            call add(a:node.content, node)
            if node.type == 'dir'
                call s:_explore(node, a:lvl+1, a:max_depth)
            end
        endfo
    endf

    let max_depth = a:0 > 0 ? a:1 : 1
    call s:_explore(self, 1, max_depth)
endf

" s:node.find({test:funcref}) -> dict
" Find the first node that satisfies the given test.
" For {node} and each of its descendants, evaluate {test} and when
" the result is true, return that node.
func! s:node.find(test)
    func! s:find_node(node, test)
        if call(a:test, [a:node])
            return a:node
        end
        for node in a:node.content
            let node = s:find_node(node, a:test)
            if !empty(node)
                return node
            end
        endfo
        return {}
    endf
    return s:find_node(self, a:test)
endf

" s:node.do({fn:funcref}) -> 0
" Execute {fn} on the current node and each of its descendants.
func! s:node.do(fn)
    func! s:_do(node, fn)
        call call(a:fn, [a:node])
        for node in a:node.content
            call s:_do(node, a:fn)
        endfo
    endf
    return s:_do(self, a:fn)
endf

" s:node.render() -> 0
" Render the directory tree in the current buffer.
func! s:node.render() abort

    let marks = {}
    if get(g:, 'loaded_bookmarks', 0)
        let marks = bookmarks#marks()
    end

    let winsave = winsaveview()
    let winid = bufwinid(b:explorer.bufnr)
    call setbufvar(b:explorer.bufnr, "&modifiable", 1)
    call setbufvar(b:explorer.bufnr, "&list", 0)
    sil! call deletebufline(b:explorer.bufnr, 1, "$")
    call clearmatches(bufwinid(b:explorer.bufnr))

    exec 'syn match' g:explorer_hl_pipe '/─/'
    exec 'syn match' g:explorer_hl_pipe '/├/'
    exec 'syn match' g:explorer_hl_pipe '/│/'
    exec 'syn match' g:explorer_hl_pipe '/└/'

    let b:explorer.map = {}

    let filters = []
    if g:explorer_filters_active
        call extend(filters, g:explorer_filters)
    end
    if !g:explorer_hidden_files
        call add(filters, {node -> node.filename() !~ '\V\^.'})
    end

    func! s:_print_tree(winid, marks, node, nr, filters, padding, is_last_child)

        let nr = a:nr + 1
        let b:explorer.map[nr] = a:node

        let filename = a:node.filename()
        let links = a:padding . (a:is_last_child ? '└─ ' : '├─ ')
        let line = links . filename

        if a:node.type == 'dir'
            call s:matchadd(a:winid, g:explorer_hl_dir, nr, len(links), len(links)+len(filename)+2)
        elseif a:node.type == 'link'
            call s:matchadd(a:winid, g:explorer_hl_link, nr, len(links), len(links)+len(filename)+2)
        end

        if has_key(a:marks, a:node.path)
            let label = printf(" [%s]", a:marks[a:node.path])
            call s:matchadd(a:winid, g:explorer_hl_mark, nr, len(line), len(line)+len(label)+1)
            let line .= label
        end

        call setbufline(b:explorer.bufnr, nr, line)

        let padding = a:padding . (a:is_last_child ? '   ' : '│  ')
        let nodes = s:filter(a:node.content, a:filters)
        let last = len(nodes)-1
        for i in range(len(nodes))
            let nr = s:_print_tree(a:winid, a:marks, nodes[i], nr, a:filters, padding, i == last)
        endfo

        return nr
    endf

    let nr = 1
    let b:explorer.map[nr] = self
    let title = self.path
    call setbufline(b:explorer.bufnr, nr, title)
    call s:matchadd(winid, g:explorer_hl_title, nr)

    let nodes = s:filter(self.content, filters)
    let last = len(nodes)-1
    for k in range(len(nodes))
        let nr = s:_print_tree(winid, marks, nodes[k], nr, filters, '', k == last)
    endfo

    call setwinvar(0, "&stl", ' ' . title)
    call setbufvar(b:explorer.bufnr, "&modifiable", 0)
    call winrestview(winsave)
endf

" s:selected_node() -> dict
" Return the node on the current line.
func! s:selected_node()
    return get(b:explorer.map, line('.'), {})
endf

" s:goto({path:string} [, {strict:number}]) -> number
" Move the cursor to the line with the given {path}.
" Unless {strict} is given and it's 1, when {path} is not found in the current
" map, the process is repeated recursively for all the parent directories.
" Returns the line number the cursor has been moved to
func! s:goto(path, ...)
    if a:path == '/'
        return 0
    end
    for [line, node] in items(b:explorer.map)
        if a:path == node.path
            call cursor(line, 1)
            redraw  " without a redraw, getwininfo does not return updated data
            let wininfo = getwininfo(bufwinid(bufnr('%')))[0]
            if line + len(node.content) > wininfo['botline']
                " move the cursor up to make space for directory content
                let offset = min([
                    \ line - wininfo['topline'],
                    \ max([
                        \ line - float2nr((wininfo['botline'] + wininfo['topline']) / 2),
                        \ len(node.content) - (wininfo['botline'] - line)
                    \ ])
                \ ])
                if offset > 0
                    " an offest of 0 still moves the cursor 1 line up
                    exec "norm!" offset . "\<c-e>"
                end
            end
            return line
        end
    endfo
    let strict = a:0 > 0 && a:1
    return strict ? 0 : s:goto(fnamemodify(a:path, ':h'))
endf

" s:goto_first_child({node:dict}) -> number
" Move the cursor to the first visible child node
" (the only case s:goto will return 1).
" A number is returned to indicate success (1) or failure (0).
func! s:goto_first_child(node)
    for [line, node] in items(b:explorer.map)
        if node.path == a:node.path
            let next = get(b:explorer.map, line+1, {})
            if !empty(next) && next.parent == a:node
                norm! j0
                return 1
            end
        end
    endfo
    return 0
endf

" s:action__info() -> 0
" Print node info.
func! s:action__info()
    let node = s:selected_node()
    if !empty(node)
        echo node.info()
    end
endf

" s:action__close_dir() -> 0
" Close the parent of the selected file or directory. Basically
" deletes all content of the parent node and redraw the directory tree.
func! s:action__close_dir() abort
    let node = s:selected_node()
    if node.type == 'dir' && empty(node.parent)
        call s:action__up_root()
        return
    end
    if empty(node) || empty(node.parent) || empty(node.parent.parent)
        return
    end
    let node.parent.content = []
    call b:explorer.tree.render()
    call s:goto(node.parent.path)
endf

" s:action__up_root() -> 0
" Set the parent of the current root directory as new root.
func! s:action__up_root() abort
    let current_path = b:explorer.tree.path
    if current_path == '/'
        return
    end
    let parent = s:path_dirname(b:explorer.tree.path)
    let b:explorer.tree = s:node.new(parent, 'dir')
    call b:explorer.tree.explore()
    call b:explorer.tree.render()
    keepj norm! gg
    call s:goto(current_path)
    norm! zz
endf

" s:action__set_root() -> 0
" Set the current selected directory as new root.
func! s:action__set_root() abort
    let node = s:selected_node()
    if empty(node)
        return
    end
    if !isdirectory(node.path)
        return s:err('Not a directory')
    end
    if empty(node.content)
        call node.explore()
    end
    let node.parent = {}
    let b:explorer.tree = node
    call b:explorer.tree.render()
    call cursor(1, 1)
    call s:goto_first_child(node)
endf

" s:action__enter_or_edit() -> 0
" Expand the selected directory or edit the selected file.
" This function is affected by counts.
" For a count {N}, expand the selected directory {N} levels deep.
" Eg. When {N} == 2, all directories inside the selected one will be expanded.
func! s:action__enter_or_edit() abort
    let node = s:selected_node()
    if empty(node)
        return
    end
    if isdirectory(node.path)
        call node.explore(v:count1)
        call b:explorer.tree.render()
        call s:goto(node.path)
        call s:goto_first_child(node)
    else
        call s:action__close()
        exec 'edit' fnameescape(node.path)
    end
endf

" s:action__auto_expand() -> 0
" Expand the selected directory 'g:explorer_expand_depth' levels deep.
func! s:action__auto_expand() abort
    let node = s:selected_node()
    if empty(node)
        return
    end
    if node.type != 'dir'
        return s:err('Not a directory')
    end
    call node.explore(g:explorer_expand_depth)
    call b:explorer.tree.render()
    call s:goto(node.path)
    call s:goto_first_child(node)
endf

" s:action__preview() -> 0
" Open the selected file in a preview window on the bottom.
func! s:action__preview() abort
    let node = s:selected_node()
    if empty(node)
        return
    end
    if isdirectory(node.path)
        return s:err('Not a file')
    end
    exec 'botright pedit' fnameescape(node.path)
endf

" s:action__create_file() -> 0
" Create a new file inside the selected directory. Intermediate directories
" are created as necessary.
func! s:action__create_file() abort
    let node = s:selected_node()
    if empty(node)
        return
    end
    if !isdirectory(node.path)
        return s:err('Not a directory')
    end
    let file = input(printf("%s\n└─ ", node.path)) | redraw
    if empty(file)
        return
    end
    let dir = fnamemodify(file, ':h')
    let path = s:path_join(node.path, dir)
    if !isdirectory(path)
        if !exists("*mkdir")
            return s:err('Cannot create intermediate directories. Functionality not available.')
        end
        try
            call mkdir(path, 'p')
        catch /E739/
            return s:err("Cannot create directory: " . dir)
        endtry
        echo "Created intermediate directory: " . dir
    end
    let path = s:path_join(node.path, file)
    if filereadable(path)
        return s:err("File already exists: " . path)
    end
    if writefile([], path) != 0
        return s:err("Cannot create file: " . path)
    end
    call node.explore()
    call b:explorer.tree.render()
    call s:goto(path)
endf

" s:action__create_directory() -> 0
" Create a new directory inside the selected directory. Intermediate directories
" are created as necessary.
func! s:action__create_directory() abort
    if !exists("*mkdir")
        return s:err('Functionality not available.')
    end
    let node = s:selected_node()
    if empty(node)
        return
    end
    if !isdirectory(node.path)
        return s:err('Not a directory')
    end
    let dir = input(printf("%s\n└─ ", node.path)) | redraw
    if empty(dir)
        return
    end
    let path = s:path_join(node.path, dir)
    if isdirectory(path) || filereadable(path)
        return s:err("File already exists: " . path)
    end
    try
        call mkdir(path, 'p')
    catch /E739/
        return s:err("Cannot create directory: " . path)
    endtry
    call node.explore()
    call b:explorer.tree.render()
    call s:goto(path)
endf

" s:action__rename() -> 0
" Rename the selected file or directory.
" The root directory cannot be renamed. One must set its parent as root first.
func! s:action__rename() abort
    let node = s:selected_node()
    if empty(node)
        return
    end
    if empty(node.parent)
        return s:err("Cannot rename root node")
    end
    if bufnr(node.path) != -1 && getbufvar(bufnr(node.path), '&mod')
        return s:err('File is open and contains changes')
    end
    let name = input(printf("%s\n%s -> ", node.parent.path, node.filename())) | redraw
    if empty(name)
        return
    end
    if name =~ '/'
        return s:err("Invalid name: " . name)
    end
    redraw
    let dest = s:path_join(node.parent.path, name)
     if isdirectory(dest) || filereadable(dest)
        return s:err("File already exists: " . dest)
    end
    if rename(node.path, dest) != 0
        return s:err("Cannot rename file: ", node.path)
    end
    if bufnr(node.path) != -1
        exec 'split' fnameescape(dest)
        close
        sil! exec 'bwipe' node.path
    end
    let node.path = dest
    let node.content = []
    call b:explorer.tree.render()
    call s:goto(dest)
endf

" s:action__delete() -> 0
" Delete the selected file or directory.
" The root directory cannot be deleted. One must set its parent as root first.
func! s:action__delete() abort
    let node = s:selected_node()
    if empty(node)
        return
    end
    if empty(node.parent)
        return s:err("Cannot delete root node")
    end
    echo printf("Deleting file: %s\nAre you sure? [yn] ", node.path)
    if nr2char(getchar()) !~ 'y'
        return
    end
    redraw
    if delete(node.path, 'rf') != 0
        return s:err("Cannot delete file: " . node.path)
    end
    sil! exec 'bwipe' node.path
    call node.parent.explore()
    call b:explorer.tree.render()
    call s:goto(node.parent.path)
endf

" s:action__toggle_filters() -> 0
" Toggle filters.
func! s:action__toggle_filters()
    let g:explorer_filters_active = 1 - g:explorer_filters_active
    let node = s:selected_node()
    call b:explorer.tree.render()
    if !empty(node)
        call s:goto(node.path)
    end
endf

" s:action__toggle_hidden_files() -> 0
" Show/hide hidden files.
func! s:action__toggle_hidden_files()
    let g:explorer_hidden_files = 1 - g:explorer_hidden_files
    let current = s:selected_node()
    call b:explorer.tree.render()
    if !empty(current)
        keepj norm! gg
        call s:goto(current.path)
        norm! zz
    end
endf

" s:action__set_cwd() -> 0
" Set current working directory
func! s:action__set_cwd()
    let node = s:selected_node()
    let cwd = isdirectory(node.path) ? node.path : node.parent.path
    exec "cd" cwd
    pwd
endf

" s:action__set_bookmarks() -> 0
" Add bookmark for the selected file or directory.
" Requires the 'bookmarks' plugin.
func! s:action__set_bookmark()
    if !get(g:, 'loaded_bookmarks', 0)
        return s:err("Bookmarks not available")
    end
    let node = s:selected_node()
    if !empty(node)
        let mark = input("Mark: ")
        call bookmarks#set(mark, node.path)
        call b:explorer.tree.render()
        call s:goto(node.path)
    end
endf

" s:action__del_bookmark() -> 0
" Delete bookmark for the selected file or directory.
" Requires the 'bookmarks' plugin.
func! s:action__del_bookmark()
    if !get(g:, 'loaded_bookmarks', 0)
        return s:err("Bookmarks not available")
    end
    let node = s:selected_node()
    if !empty(node)
        call bookmarks#unset(node.path)
        call b:explorer.tree.render()
        call s:goto(node.path)
    end
endf

" s:action__close() -> 0
" Close the window.
func! s:action__close()
    close
endf

" s:action__help() -> 0
" Show very basic help.
func! s:action__help()
    let help = __explorer_mappings_help()
    let out = []
    let width = 1
    for [mappings, _] in help
        let str = join(mappings, ', ')
        if len(str) > width
            let width = len(str)
        end
    endfor
    for [mappings, helpmsg] in help
        call add(out, printf("%-".width."s   %s", join(mappings, ', '), helpmsg))
    endfor
    echo join(out, "\n")
endf

" s:path_join([{path:string}, ...]) -> string
" Join paths. Trailing slashes are trimmed.
func! s:path_join(...)
    let args = filter(copy(a:000), {-> !empty(v:val)})
    let path = substitute(join(args, '/'), '\v/+', '/', 'g')
    return substitute(path, '\v/+$', '', '')
endf

" s:path_dirname({path:string}) -> string
" Return the directory name of {path}.
func! s:path_dirname(path)
    let dirname = fnamemodify(substitute(a:path, '\v/+$', '', ''), ':h')
    return dirname != '.' ? dirname : ''
endf

" s:matchadd({winid:number}, {group:string}, {line:number}, [, {start:number}, [, {end:number}]]) -> 0
" Highlight a {line} with the given highlight {group}.
" If neither {start} or {end} are given, the whole line is highlighted.
" If only {start} is given, the line is highlighted starting from the column {start}.
" If only {end} is given, the line is highlighted from {start} to {end}.
func! s:matchadd(winid, group, line, ...)
    let start = a:0 > 0 && type(a:1) == v:t_number ? '%>'.a:1.'c.*' : ''
    let end = a:0 > 1 && type(a:2) == v:t_number ? '%<'.a:2.'c' : ''
    let line = '%'.a:line.'l' . (empty(start.end) ? '.*' : '')
    let pattern = printf('\v%s%s%s', line, start, end)
    return matchadd(a:group, pattern, -1, -1, #{window: a:winid})
endf

" s:prettify_path({path:string}) -> string
" Prettify the given {path} by trimming the current working directory.
" If not successful, try to reduce file name to be relative to the
" home directory (much like using ':~')
func! s:prettify_path(path)
    let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
    return substitute(path, '\V\^'.$HOME, '~', '')
endf

" s:filter({list:list}, {filters:list}) -> list
" Return a list of all the {list} items that satisfy all {filters}.
" {filters} is expected to be a list of Funcrefs.
" The original {list} is not modified.
func! s:filter(list, filters)
    let filtered = []
    for item in a:list
        let add = 1
        for F in a:filters
            if !call(F, [item])
                let add = 0
                break
            end
        endfo
        if add
            call add(filtered, item)
        end
    endfo
    return filtered
endf

func! s:err(fmt, ...)
    echohl WarningMsg | echom call('printf', [a:fmt] + a:000)  | echohl None
endf
