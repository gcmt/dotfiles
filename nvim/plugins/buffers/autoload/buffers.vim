
let s:bufname = '__buffers__'

" View loaded buffers
"
" Args:
"   - all (bool): whether or not unlisted buffers are also displayed
"
func! buffers#view(all) abort

    let buffers = s:get_buffers(a:all, g:buffers_sorting)
    if bufwinnr(s:bufname) != -1 || !len(buffers)
        return
    end

    " current buffer and window number
    let curr_bufnr = bufnr('%')
    let curr_winnr = winnr()

    exec 'sil keepj keepa botright 1new' s:bufname

    let winnr = bufwinnr(s:bufname)
    let winid = win_getid(winnr)

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

    call setbufvar(bufnr, '&filetype', 'buffers')
    call setbufvar(bufnr, '&buftype', 'nofile')
    call setbufvar(bufnr, '&bufhidden', 'hide')
    call setbufvar(bufnr, '&buflisted', 0)

    let table = s:render(winid, bufnr, buffers)

    let ctx = #{
        \ winid: winid,
        \ winnr: winnr,
        \ bufnr: bufnr,
        \ table: table,
        \ curr_bufnr: curr_bufnr,
        \ curr_winnr: curr_winnr,
        \ selected: 1,
        \ all: a:all,
        \ action: '',
    \ }

    " position the cursor to the current buffer
    for [line, b] in items(table)
        if b == curr_bufnr
            let ctx.selected = line
            break
        end
    endfor

    " hide statusbar
    exec 'au BufHidden <buffer='.bufnr.'> let &laststatus = ' getwinvar(winnr, "&laststatus")
    call setwinvar(winnr, '&laststatus', '0')

    call s:setup_mappings(g:buffers_mappings, ctx)
    call s:resize_window(ctx, g:buffers_maxheight)
endf


" Execute the given action.
"
" Args:
"   - action (string): the action to perform
"   - ctx (dict): context info
"   - close_fn (func): function used to close the buffers list window

func s:do_action(action, ctx, close_fn = v:none)
    let a:ctx.action = a:action
    if a:action =~ '\v^(edit|tab|split|vsplit)$'
        if s:buf_edit(a:ctx) && type(a:close_fn) == v:t_func
            call a:close_fn()
        end
    elseif a:action =~ '\v^(bdelete|bwipe|bunload)!?$'
        call s:buf_delete(a:ctx)
        if empty(a:ctx.table) && type(a:close_fn) == v:t_func
            call a:close_fn()
        end
    elseif a:action == 'toggle_unlisted'
        call s:toggle_unlisted(a:ctx)
        if empty(a:ctx.table) && type(a:close_fn) == v:t_func
            call a:close_fn()
        end
    elseif a:action =~ 'quit' || a:action =~ 'fm'
        if type(a:close_fn) == v:t_func
            call a:close_fn()
        end
        if a:action =~ 'fm'
            exec 'Fm' expand('%:p')
        end
    else
        call s:err("Unknown action: " . a:action)
    end
endf


" Setup mappings from the current window.
"
" Args:
"  - mappings (dict): a dictionary of mappings {lhs: rhs}
"  - ctx (dict): context info
"
func! s:setup_mappings(mappings, ctx)

    let ctx = a:ctx
    func! s:_do(action) closure
        let _ctx = extend(ctx, #{selected: line('.')})
        let Close_fn = function('win_execute', [bufwinid(_ctx.bufnr), 'close'])
        return s:do_action(a:action, _ctx, Close_fn)
    endf

    func! s:_nnoremap(lhs, rhs)
        exec "nnoremap" "<nowait> <silent> <buffer>" a:lhs a:rhs . "<cr>"
    endf

    mapclear <buffer>

    for [char, action] in items(a:mappings)
        if char =~ '\v^\\'
            let char = char[1:]
        end
        if action == '@quit'
            let action = ':close'
        elseif action == '@quit'
            let action = ':close<cr>:Files!'
        end
        if action =~ '\v^\@'
            call s:_nnoremap(char, ":call <sid>_do('".action[1:]."')")
        elseif action =~ '\v^:'
            call s:_nnoremap(char, action)
        end
    endfo

endf


" Render the buffers list in the given buffer.
"
" Args:
"  - winid (number): the window id
"  - bufnr (number): the buffer number where buffers need to be rendered
"  - buffers (list): list of buffers to render
"
" Returns:
"   - table (dict): a dictionary that maps buffer numbers to buffer lines
"
func! s:render(winid, bufnr, buffers)

    call setbufvar(a:bufnr, "&modifiable", 1)
    sil! call deletebufline(a:bufnr, 1, "$")
    call clearmatches()

    let tails = {}
    for bufnr in a:buffers
        let tail = fnamemodify(bufname(bufnr), ':t')
        let tails[tail] = get(tails, tail) + 1
    endfo

    let fmt = g:buffers_line_format

    let marks = {}
    if g:buffers_show_bookmarks && exists("*bookmarks#marks")
        for [letter, path] in items(bookmarks#marks())
            let marks[path] = letter
        endfor
    end

    let table = {}
    let i = 1

    for b in a:buffers

        let table[i] = b

        let is_unnamed = empty(bufname(b))
        let is_terminal = getbufvar(b, '&bt') == 'terminal'
        let is_modified = getbufvar(b, '&mod')
        let is_directory = isdirectory(bufname(b))

        let bufname = bufname(b)
        let fullpath = fnamemodify(bufname, ':p')
        let bufpath = ""

        if is_unnamed
            let bufname = b
            let bufpath = g:buffers_label_unnamed
        elseif is_terminal
            let bufpath = g:buffers_label_terminal
        else
            let bufpath = s:prettify_path(fullpath)
            let bufname =  fnamemodify(bufpath, ':t')
            if get(tails, bufname) > 1
                let bufname = join(split(fullpath, '/')[-2:], '/')
            end
        end

        if len(split(bufpath, '/')) <= 1 && !is_terminal && !is_unnamed
            let bufpath = ""
        end

        let hlmap = copy(g:buffers_highlight)
        let bufname_hl = buflisted(b) ? get(hlmap, "bufname") : get(hlmap, "is_unlisted")
        let bufname_hl = is_modified ? get(hlmap, "is_modified") : bufname_hl
        let bufname_hl = is_terminal ? get(hlmap, "is_terminal") : bufname_hl
        let bufname_hl = is_directory ? get(hlmap, "is_directory") : bufname_hl
        let hlmap.bufname = bufname_hl

        let repl = #{
            \ bufname: bufname,
            \ bufpath: bufpath,
            \ mark: get(marks, fullpath, ''),
        \ }

        let [line, positions] = util#fmt(fmt, repl, 1)
        call setbufline(a:bufnr, i, line)
        call s:set_matches(a:winid, i, positions, hlmap)

        let i += 1

    endfo

    call setbufvar(a:bufnr, "&modifiable", 0)

    return table

endf


" Set highlight matches
"
" Args:
"  - winid (number): the window id
"  - line (number): the lien number where matches need to be set
"  - positions (list): list of matches positions
"  - hl_map (dict): maps format string labels to highlight groups
"
func s:set_matches(winid, line, positions, hl_map) abort
    for pos in a:positions
        let pattern = '\v%' . a:line . 'l%>' . pos[1] . 'c.*%<' . (pos[2]+2) . 'c'
        call matchadd(a:hl_map[pos[0]], pattern, -1, -1, #{window: a:winid})
    endfo
endf


" Edit the buffer under cursor.
" The editing mode depends on the value of `a:ctx.action`.
"
" Args:
"  - ctx (dict): context info
"
func! s:buf_edit(ctx) abort

    " move to the window the user came from
    exec a:ctx.curr_winnr 'wincmd w'

    let target = get(a:ctx.table, string(a:ctx.selected) , '')
    if target == a:ctx.curr_bufnr
        return 1
    end

    let winid = win_getid(a:ctx.curr_winnr)
    let is_terminal = getbufvar(target, '&bt') == 'terminal'

    let commands = {'tab': 'tab split', 'split': 'split', 'vsplit': 'vsplit'}
    sil exec get(commands, a:ctx.action, is_terminal ? 'split' : '')

    if is_terminal || empty(bufname(target))
        sil exec 'buffer' target
    else
        sil exec 'edit' fnameescape(bufname(target))
    end

    return 1
endf


" Delete/wipe/unload the buffer under cursor.
"
" Args:
"  - ctx (dict): context info
"
func! s:buf_delete(ctx) abort

    let target = get(a:ctx.table, string(a:ctx.selected), '')
    let buffers = sort(values(a:ctx.table), 'n')

    " select the next buffer as a replacement for every window that contains the
    " buffer `target`
    let repl = buffers[(index(buffers, target)+1) % len(buffers)]

    if repl == target
        if empty(bufname(target))
            " there are no more named buffers to switch to
            return
        end
        call win_execute(bufwinid(target), 'enew')
    else
        while bufwinid(target) != -1
            call win_execute(bufwinid(target), 'buffer ' . repl)
        endw
    end

    let is_terminal = getbufvar(target, '&buftype') == 'terminal'
    let cmd = is_terminal ? 'bwipe!' : a:ctx.action

    try
        exec cmd target
    catch /E.*/
        return s:err(matchstr(v:exception, '\vE\d+:.*'))
    endtry

    let buffers = s:get_buffers(a:ctx.all, g:buffers_sorting)
    let a:ctx.table = s:render(a:ctx.winid, a:ctx.bufnr, buffers)

    call s:resize_window(a:ctx, g:buffers_maxheight)
endf


" Toggle visibility of unlisted buffers.
"
" Args:
"  - ctx (dict): context info
"
func! s:toggle_unlisted(ctx)

    let selected_bufnr = get(a:ctx.table, string(a:ctx.selected), '')

    let a:ctx.all = 1 - a:ctx.all
    let buffers = s:get_buffers(a:ctx.all, g:buffers_sorting)
    let a:ctx.table = s:render(a:ctx.winid, a:ctx.bufnr, buffers)

    " Follow the previously selected buffer
    for [line, bufnr] in items(a:ctx.table)
        if bufnr == selected_bufnr
            let a:ctx.selected = line
            break
        end
    endfo

    call win_execute(bufwinid(a:ctx.bufnr), a:ctx.selected)
    call win_execute(bufwinid(a:ctx.bufnr), 'norm! 0')

    call s:resize_window(a:ctx, g:buffers_maxheight)
endf


" Return a list of all loaded or listed buffers.
" Buffers are sorted according to the value of g:buffers_sorting. Sorting
" defaults to numerical.
"
" Args:
"   - all (bool): if it's true, unlisted buffers are also returned
"
" Returns:
"   - buffers (list): a list of buffer numbers
"
func! s:get_buffers(all, sorting = 'numerical')
    let F1 = a:all ? function('bufexists') : function('buflisted')
    let F2 = {i, nr -> F1(nr) && getbufvar(nr, '&buftype') =~ '\v^(terminal)?$'}
    let buffers = filter(range(1, bufnr('$')), F2)
    call map(buffers, {i, b -> [b, fnamemodify(bufname(b), ':t')]})
    if a:sorting == 'alphabetical'
        call sort(buffers, {a, b -> char2nr(a[1]) - char2nr(b[1])})
    end
    return map(buffers, {i, v -> v[0]})
endf


" Prettify the given path by trimming the current working directory. If not
" successful, try to reduce file name to be relative to the home directory.
"
" Args:
"   - path (string): the path to prettify
"
" Returns:
"   - path (string): the prettified path
"
func! s:prettify_path(path)
    let repl = getcwd() != $HOME ? '\V\^'.getcwd().'/' : ''
    let path = substitute(a:path, repl, '', '')
    let path = substitute(path, '\v/$', '', '')
    let path = substitute(path, '\V\^'.$HOME, '~', '')
    return path
endf


" Resize the buffers window to fit exactly the content.
"
" Args:
"   - ctx (dict): context info
"   - max_height (number): window height as percentage of the Vim window
"
func! s:resize_window(ctx, max_height) abort

    if winnr() != bufwinnr(a:ctx.bufnr)
        return
    end

    let max = float2nr(&lines * a:max_height / 100)
    sil exec 'resize ' . min([line('$'), max])

    " push the last line to the bottom in order to not have any empty space
    call cursor(1, line('$'))
    norm! zb

    call cursor(a:ctx.selected, 1)

    " unless at the very bottom, center the cursor position
    if line('.') < (line('$') - winheight(0)/2)
        norm! zz
    end

endf


" Display a simple error message.
"
" Args:
"   - msg (string): the error message
"
func! s:err(msg)
    echohl WarningMsg | echo a:msg | echohl None
endf
