
" s:selected_node() -> dict
" Return the node on the current line.
func! s:selected_node()
    return get(b:explorer.map, line('.'), {})
endf

" explorer#actions#goto({path:string} [, {strict:number}]) -> number
" Move the cursor to the line with the given {path}.
" Unless {strict} is given and it's 1, when {path} is not found in the current
" map, the process is repeated recursively for all the parent directories.
func! explorer#actions#goto(path, ...)
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
    return strict ? 0 : explorer#actions#goto(parent)
endf

" explorer#actions#goto_first_child({node:dict}) -> number
" Move the cursor to the first visible (the only case explorer#actions#goto
" will return 1) child node.
" A number is returned to indicate success (1) or failure (0).
func! explorer#actions#goto_first_child(node)
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

" explorer#actions#info() -> 0
" Print node info.
func! explorer#actions#info()
    let node = s:selected_node()
    if !empty(node)
        echo node.info()
    end
endf

" explorer#actions#close_dir() -> 0
" Close the parent of the selected file or directory. Basically
" deletes all content of the parent node and redraw the directory tree.
func! explorer#actions#close_dir() abort
    let node = s:selected_node()
    if empty(node) || empty(node.parent) || empty(node.parent.parent)
        return
    end
    let node.parent.content = []
    call b:explorer.tree.render()
    call explorer#actions#goto(node.parent.path)
endf

" explorer#actions#up_root() -> 0
" Set the parent of the current root directory as new root.
func! explorer#actions#up_root() abort
    let current = b:explorer.tree.path
    let parent = explorer#path#dirname(b:explorer.tree.path)
    let b:explorer.tree = explorer#tree#new_node(parent, 'dir')
    call b:explorer.tree.explore()
    call b:explorer.tree.render()
    call explorer#actions#goto(current)
endf

" explorer#actions#set_root() -> 0
" Set the current selected directory as new root.
func! explorer#actions#set_root() abort
    let node = s:selected_node()
    if empty(node)
        return
    end
    if !isdirectory(node.path)
        return explorer#err('Not a directory')
    end
    if empty(node.content)
        call node.explore()
    end
    let node.parent = {}
    let b:explorer.tree = node
    call b:explorer.tree.render()
    call explorer#actions#goto_first_child(node)
endf

" explorer#actions#enter_or_edit() -> 0
" Expand the selected directory or edit the selected file.
" This function is affected by counts.
" For a count {N}, expand the selected directory {N} levels deep.
" Eg. When {N} == 2, all directories inside the selected one will be expanded.
func! explorer#actions#enter_or_edit() abort
    let node = s:selected_node()
    if empty(node)
        return
    end
    if isdirectory(node.path)
        call node.explore(v:count1)
        call b:explorer.tree.render()
        call explorer#actions#goto(node.path)
        call explorer#actions#goto_first_child(node)
        return
    end
    let current = b:explorer.current
    exec 'edit' fnameescape(node.path)
    let @# = buflisted(current) ? current : bufnr('%')
endf

" explorer#actions#auto_expand() -> 0
" Expand the selected directory 'g:explorer_expand_depth' levels deep.
func! explorer#actions#auto_expand() abort
    let node = s:selected_node()
    if empty(node)
        return
    end
    if node.type != 'dir'
        return explorer#err('Not a directory')
    end
    call node.explore(g:explorer_expand_depth)
    call b:explorer.tree.render()
    call explorer#actions#goto(node.path)
    call explorer#actions#goto_first_child(node)
endf

" explorer#actions#preview() -> 0
" Open the selected file in a preview window on the bottom.
func! explorer#actions#preview() abort
    let node = s:selected_node()
    if empty(node)
        return
    end
    if isdirectory(node.path)
        return explorer#err('Not a file')
    end
    exec 'botright pedit' fnameescape(node.path)
endf

" explorer#actions#create_file() -> 0
" Create a new file inside the selected directory. Intermediate directories
" are created as necessary.
func! explorer#actions#create_file() abort
    let node = s:selected_node()
    if empty(node)
        return
    end
    if !isdirectory(node.path)
        return explorer#err('Not a directory')
    end
    let file = input(printf("%s\n└─ ", node.path)) | redraw
    if empty(file)
        return
    end
    let dir = fnamemodify(file, ':h')
    let path = explorer#path#join(node.path, dir)
    if !isdirectory(path)
        if !exists("*mkdir")
            return explorer#err('Cannot create intermediate directories. Functionality not available.')
        end
        try
            call mkdir(path, 'p')
        catch /E739/
            return explorer#err("Cannot create directory: " . dir)
        endtry
        echo "Created intermediate directory: " . dir
    end
    let path = explorer#path#join(node.path, file)
    if filereadable(path)
        return explorer#err("File already exists: " . path)
    end
    if writefile([], path) != 0
        return explorer#err("Cannot create file: " . path)
    end
    call node.explore()
    call b:explorer.tree.render()
    call explorer#actions#goto(path)
endf

" explorer#actions#create_directory() -> 0
" Create a new directory inside the selected directory. Intermediate directories
" are created as necessary.
func! explorer#actions#create_directory() abort
    if !exists("*mkdir")
        return explorer#err('Functionality not available.')
    end
    let node = s:selected_node()
    if empty(node)
        return
    end
    if !isdirectory(node.path)
        return explorer#err('Not a directory')
    end
    let dir = input(printf("%s\n└─ ", node.path)) | redraw
    if empty(dir)
        return
    end
    let path = explorer#path#join(node.path, dir)
    if isdirectory(path) || filereadable(path)
        return explorer#err("File already exists: " . path)
    end
    try
        call mkdir(path, 'p')
    catch /E739/
        return explorer#err("Cannot create directory: " . path)
    endtry
    call node.explore()
    call b:explorer.tree.render()
    call explorer#actions#goto(path)
endf

" explorer#actions#rename() -> 0
" Rename the selected file or directory.
" The root directory cannot be renamed. One must set its parent as root first.
func! explorer#actions#rename() abort
    let node = s:selected_node()
    if empty(node)
        return
    end
    if empty(node.parent)
        return explorer#err("Cannot rename root node")
    end
    if bufnr(node.path) != -1 && getbufvar(bufnr(node.path), '&mod')
        return explorer#err('File is open and contains changes')
    end
    let name = input(printf("%s\n└─ %s -> ", node.parent.path, node.filename())) | redraw
    if empty(name)
        return
    end
    if name =~ '/'
        return explorer#err("The new file name should not contain '/' characters")
    end
    redraw
    let to = explorer#path#join(node.parent.path, name)
     if isdirectory(to) || filereadable(to)
        return explorer#err("File already exists: " . to)
    end
    if rename(node.path, to) != 0
        return explorer#err("Cannot rename file: ", node.path)
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
    call explorer#actions#goto(to)
endf

" explorer#actions#delete() -> 0
" Delete the selected file or directory.
" The root directory cannot be deleted. One must set its parent as root first.
func! explorer#actions#delete() abort
    let node = s:selected_node()
    if empty(node)
        return
    end
    if empty(node.parent)
        return explorer#err("Cannot delete root node")
    end
    echo printf("Deleting file: %s\nAre you sure? [yn] ", node.path)
    if nr2char(getchar()) !~ 'y'
        return
    end
    redraw
    if delete(node.path, 'rf') != 0
        return explorer#err("Cannot delete file: " . node.path)
    end
    sil! exec 'bwipe' node.path
    call node.parent.explore()
    call b:explorer.tree.render()
    call explorer#actions#goto(node.parent.path)
endf

" explorer#actions#toggle_filters() -> 0
" Toggle filters.
func! explorer#actions#toggle_filters()
    let g:explorer_filters_active = 1 - g:explorer_filters_active
    let node = s:selected_node()
    call b:explorer.tree.render()
    if !empty(node)
        call explorer#actions#goto(node.path)
    end
endf

" explorer#actions#toggle_hidden_files() -> 0
" Show/hide hidden files.
func! explorer#actions#toggle_hidden_files()
    let g:explorer_hidden_files = 1 - g:explorer_hidden_files
    let current = s:selected_node()
    call b:explorer.tree.render()
    if !empty(current)
        call explorer#actions#goto(current.path)
    end
endf

" explorer#actions#bookmarks_set({mark:number}) -> 0
" Add bookmark for the selected file or directory.
" Requires the 'bookmarks' plugin.
func! explorer#actions#bookmarks_set(mark)
    if !get(g:, 'loaded_bookmarks')
        return explorer#err("Bookmarks not available")
    end
    let node = s:selected_node()
    if !empty(node)
        call bookmarks#set(a:mark, node.path)
    end
endf

" explorer#actions#close() -> 0
" Close the Explorer buffer.
func! explorer#actions#close()
    if get(w:, 'explorer', 0)
        close
    elseif buflisted(b:explorer.current)
        exec 'buffer' b:explorer.current
    else
        enew
    end
endf

" explorer#actions#help() -> 0
" Show very basic help.
func! explorer#actions#help()
    let mappings = sort(filter(split(execute('nmap'), "\n"), {-> v:val =~ '\vexplorer#'}))
    call map(mappings, {-> substitute(v:val, '\V\(\^n  \|\(*@\)\?:\(<C-U>\)\?call explorer#\(actions\|buffer\)#\|<CR>\$\)', '', 'g')})
    echo join(mappings, "\n")
endf
