
let s:node = {}

" Restore alternate buffer
func! s:restore_alternate()
    for nr in [b:explorer.alt, b:explorer.current] + range(1, bufnr('$'))
        if buflisted(nr)
            let @# = nr
            break
        end
    endfo
endf

aug _explorer
    au!
    au BufLeave __explorer__ call <sid>restore_alternate()
aug END

func! explorer#open(target, curwin) abort

    let target = a:target
    let curwin = a:curwin

    if !empty(target)
        if !isdirectory(target) && !filereadable(target)
            return s:err("Invalid file or directory: %s", target)
        end
    end

    let explorer = {}

    if exists('b:explorer')
        let explorer = b:explorer
        let curwin = 1
    else
        let explorer.current = bufnr('%')
        let explorer.alt = bufnr('#')
    end

    if curwin
        sil edit __explorer__
    else
        sil keepj keepa botright new __explorer__
        let w:explorer = 1
    end

    setl filetype=explorer buftype=nofile bufhidden=hide nobuflisted
    setl noundofile nobackup noswapfile nospell
    setl nowrap nonumber norelativenumber nolist textwidth=0
    setl cursorline nocursorcolumn colorcolumn=0

    call s:setup_mappings()

    let b:explorer = extend(get(b:, 'explorer', {}), explorer)

    if empty(get(b:explorer, 'tree', {}))
        let target = fnamemodify(bufname(b:explorer.current), ':p')
    end

    if !empty(target)

        let target = substitute(fnamemodify(target, ':p'), '\v/+$', '', '')

        if isdirectory(target)
            let dir = target
        else
            let dir = fnamemodify(target, ':h')
        end

        let b:explorer.tree = s:node.new_node(dir, 'dir')
        call b:explorer.tree.explore()
        call b:explorer.tree.render()

        if filereadable(target)
            let path = target
        else
            let path = fnamemodify(bufname(b:explorer.current), ':p')
        end

        if !s:action__goto(path)
            call s:action__goto_first_child(b:explorer.tree)
        end

        if line('w0') > 1
            norm! zz
        end

    else

        let winsave = winsaveview()
        call b:explorer.tree.render()
        call winrestview(winsave)

    end

endf


" s:node.new_node({path:string}, {type:string}[, {parent:dict}]) -> dict
" Create a new node for the given {path} with type {type}.
" An optional {parent} node might be given as well.
func s:node.new_node(path, type, ...)
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
    let cmd = 'ls -1AH ' . shellescape(self.path)
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
            let node = s:node.new_node(path, getftype(path), a:node)
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

" s:node.rename({path:string}) -> 0
" Set current node path to {path} and updates all its descendant nodes.
func! s:node.rename(path)
    let old = self.path
    let Fn = {node -> node.set_path(substitute(node.path, '\V\^'.old, a:path, ''))}
    return self.do(Fn)
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

    syn clear
    setl modifiable
    sil %delete _

    syn match ExplorerPipe /─/
    syn match ExplorerPipe /├/
    syn match ExplorerPipe /│/
    syn match ExplorerPipe /└/

    let b:explorer.map = {}

    let filters = []
    if g:explorer_filters_active
        call extend(filters, g:explorer_filters)
    end
    if !g:explorer_hidden_files
        call add(filters, {node -> node.filename() !~ '\V\^.'})
    end

    func! s:_print_tree(node, nr, filters, padding, is_last_child)

        let nr = a:nr + 1
        let b:explorer.map[nr] = a:node

        let filename = a:node.filename()

        let links = a:padding . (a:is_last_child ? '└─ ' : '├─ ')

        let line = links . filename

        if a:node.type == 'dir'
            call s:highlight('ExplorerDir', nr, len(links), len(links)+len(filename)+2)
        elseif a:node.type == 'link'
            call s:highlight('ExplorerLink', nr, len(links), len(links)+len(filename)+2)
        end

        call setline(nr, line)

        let padding = a:padding . (a:is_last_child ? '   ' : '│  ')

        let nodes = s:directories_first(s:filter(a:node.content, a:filters))
        let last = len(nodes)-1
        for i in range(len(nodes))
            let nr = s:_print_tree(nodes[i], nr, a:filters, padding, i == last)
        endfo

        return nr

    endf

    let nr = 1

    let b:explorer.map[nr] = self

    let title = self.path
    call setline(nr, title)
    call s:highlight('ExplorerTitle', nr)

    let nodes = s:directories_first(s:filter(self.content, filters))
    let last = len(nodes)-1
    for k in range(len(nodes))
        let nr = s:_print_tree(nodes[k], nr, filters, '', k == last)
    endfo

    call setwinvar(0, "&stl", ' ' . title)
    setl nomodifiable

endf

" s:directories_first({list:dict}) -> list
" Order a list of nodes by putting directories first.
" Sorting doesn't happen in-place, a new list is returned.
func! s:directories_first(nodes)
    let Fn = {a, b -> a.type == b.type ? 0 : a.type != 'dir' ? 1 : -1}
    return sort(copy(a:nodes), Fn)
endf

" s:selected_node() -> dict
" Return the node on the current line.
func! s:selected_node()
    return get(b:explorer.map, line('.'), {})
endf

" s:setup_mappings() -> 0
" Setup action mappings
func! s:setup_mappings()
    exec 'nnoremap <silent> <buffer> l :<c-u>call <sid>action__enter_or_edit()<cr>'
    exec 'nnoremap <silent> <buffer> <enter> :call <sid>action__enter_or_edit()<cr>'
    exec 'nnoremap <silent> <buffer> q :call <sid>action__close()<cr>'
    exec 'nnoremap <silent> <buffer> i :call <sid>action__info()<cr>'
    exec 'nnoremap <silent> <buffer> p :call <sid>action__preview()<cr>'
    exec 'nnoremap <silent> <buffer> x :call <sid>action__auto_expand()<cr>'
    exec 'nnoremap <silent> <buffer> h :call <sid>action__close_dir()<cr>'
    exec 'nnoremap <silent> <buffer> L :call <sid>action__set_root()<cr>'
    exec 'nnoremap <silent> <buffer> H :call <sid>action__up_root()<cr>'
    exec 'nnoremap <silent> <buffer> a :call <sid>action__toggle_hidden_files()<cr>'
    exec 'nnoremap <silent> <buffer> f :call <sid>action__toggle_filters()<cr>'
    exec 'nnoremap <silent> <buffer> % :call <sid>action__create_file()<cr>'
    exec 'nnoremap <silent> <buffer> c :call <sid>action__create_directory()<cr>'
    exec 'nnoremap <silent> <buffer> r :call <sid>action__rename()<cr>'
    exec 'nnoremap <silent> <buffer> d :call <sid>action__delete()<cr>'
    exec 'nnoremap <silent> <buffer> b :call <sid>action__bookmarks_set(getchar())<cr>'
    exec 'nnoremap <silent> <buffer> ? :call <sid>action__help()<cr>'
endf

" s:action__goto({path:string} [, {strict:number}]) -> number
" Move the cursor to the line with the given {path}.
" Unless {strict} is given and it's 1, when {path} is not found in the current
" map, the process is repeated recursively for all the parent directories.
func! s:action__goto(path, ...)
    if a:path == '/'
        return 0
    end
    for [line, node] in items(b:explorer.map)
        if a:path == node.path
            exec line
            norm! 0
            return 1
        end
    endfo
    let strict = a:0 > 0 && a:1
    let parent = fnamemodify(a:path, ':h')
    return strict ? 0 : s:action__goto(parent)
endf

" s:action__goto_first_child({node:dict}) -> number
" Move the cursor to the first visible (the only case s:action__goto
" will return 1) child node.
" A number is returned to indicate success (1) or failure (0).
func! s:action__goto_first_child(node)
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
    if empty(node) || empty(node.parent) || empty(node.parent.parent)
        return
    end
    let node.parent.content = []
    call b:explorer.tree.render()
    call s:action__goto(node.parent.path)
endf

" s:action__up_root() -> 0
" Set the parent of the current root directory as new root.
func! s:action__up_root() abort
    let current = b:explorer.tree.path
    let parent = s:path_dirname(b:explorer.tree.path)
    let b:explorer.tree = s:node.new_node(parent, 'dir')
    call b:explorer.tree.explore()
    call b:explorer.tree.render()
    call s:action__goto(current)
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
    call s:action__goto_first_child(node)
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
        call s:action__goto(node.path)
        call s:action__goto_first_child(node)
        return
    end
    let current = b:explorer.current
    exec 'edit' fnameescape(node.path)
    let @# = buflisted(current) ? current : bufnr('%')
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
    call s:action__goto(node.path)
    call s:action__goto_first_child(node)
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
    call s:action__goto(path)
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
    call s:action__goto(path)
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
    let name = input(printf("%s\n└─ %s -> ", node.parent.path, node.filename())) | redraw
    if empty(name)
        return
    end
    if name =~ '/'
        return s:err("The new file name should not contain '/' characters")
    end
    redraw
    let to = s:path_join(node.parent.path, name)
     if isdirectory(to) || filereadable(to)
        return s:err("File already exists: " . to)
    end
    if rename(node.path, to) != 0
        return s:err("Cannot rename file: ", node.path)
    end
    if bufnr(node.path) != -1
        exec 'split' fnameescape(to)
        close
        if bufnr(@#) == bufnr(node.path)
            let @# = bufnr(to)
        end
        if b:explorer.current == bufnr(node.path)
            let b:explorer.current = bufnr(to)
        end
        if b:explorer.alt == bufnr(node.path)
            let b:explorer.alt = bufnr(to)
        end
        sil! exec 'bwipe' node.path
    end
    call node.rename(to)
    call b:explorer.tree.render()
    call s:action__goto(to)
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
    call s;action__goto(node.parent.path)
endf

" s:action__toggle_filters() -> 0
" Toggle filters.
func! s:action__toggle_filters()
    let g:explorer_filters_active = 1 - g:explorer_filters_active
    let node = s:selected_node()
    call b:explorer.tree.render()
    if !empty(node)
        call s:action__goto(node.path)
    end
endf

" s:action__toggle_hidden_files() -> 0
" Show/hide hidden files.
func! s:action__toggle_hidden_files()
    let g:explorer_hidden_files = 1 - g:explorer_hidden_files
    let current = s:selected_node()
    call b:explorer.tree.render()
    if !empty(current)
        call s:action__goto(current.path)
    end
endf

" s:action__bookmarks_set({mark:number}) -> 0
" Add bookmark for the selected file or directory.
" Requires the 'bookmarks' plugin.
func! s:action__bookmarks_set(mark)
    if !get(g:, 'loaded_bookmarks')
        return s:err("Bookmarks not available")
    end
    let node = s:selected_node()
    if !empty(node)
        call bookmarks#set(a:mark, node.path)
    end
endf

" s:action__close() -> 0
" Close the Explorer buffer.
func! s:action__close()
    if get(w:, 'explorer', 0)
        close
    elseif buflisted(b:explorer.current)
        exec 'buffer' b:explorer.current
    else
        enew
    end
endf

" TODO
" s:action__help() -> 0
" Show very basic help.
func! s:action__help()
    let mappings = ["todo"]
    "let mappings = sort(filter(split(execute('nmap'), "\n"), {-> v:val =~ '\vexplorer#'}))
    "call map(mappings, {-> substitute(v:val, '\V\(\^n  \|\(*@\)\?:\(<C-U>\)\?call explorer#\(actions\|buffer\)#\|<CR>\$\)', '', 'g')})
    echo join(mappings, "\n")
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
    let dirname = fnamemodify(a:path, ':h')
    return dirname != '.' ? dirname : ''
endf

" TODO: use matchadd
" s:highlight({group:string}, {line:number}, [, {start:number}, [, {end:number}]]) -> 0
" Highlight a {line} with the given highlight {group}.
" If neither {start} or {end} are given, the whole line is highlighted.
" If only {start} is given, the line is highlighted starting from the column {start}.
" If only {end} is given, the line is highlighted from {start} to {end}.
func! s:highlight(group, line, ...)
    let start = a:0 > 0 && type(a:1) == v:t_number ? '%>'.a:1.'c.*' : ''
    let end = a:0 > 1 && type(a:2) == v:t_number ? '%<'.a:2.'c' : ''
    let line = '%'.a:line.'l' . (empty(start.end) ? '.*' : '')
    exec printf('syn match %s /\v%s%s%s/', a:group, line, start, end)
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
