
let s:bufname = '__marks__'

" Automatically mark the current line.
" If the mark already exists, it is deleted.
"
" Args:
"   - local (bool) -> whether or not the marks should be local to the current
"   buffer (a lowercase letter is used to set the mark)
"
func marks#set_auto(local) abort

    let marks = s:get_marks(bufnr('%'))
    let bufpath = fnamemodify(bufname('%'), ':p')

    " Check if the mark is already set on the current line and if so, delete it
    for mark in values(marks)
        if mark.file ==# bufpath && mark.linenr == line('.') && mark.line ==# getline('.')
            exec 'delmarks' mark.letter
            echo printf("line \"%s\" unmarked [%s]", line('.'), mark.letter)
            return
        end
    endfo

    let letters = a:local ? 'abcdefghijklmnopqrstuvwxyz' : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    for letter in split(letters, '\ze')
        if !has_key(marks, letter)
            exec 'mark' letter
            echo printf("line \"%s\" marked with [%s]", line('.'), letter)
            return
        end
    endfo

    call s:err("No more marks available")
endf

" Open the buffer where marks will be displayed
func marks#view() abort

    let marks = s:get_marks(bufnr('%'))
    if bufwinnr(s:bufname) != -1
        return
    end

    let curr_bufnr = bufnr('%')
    let curr_winnr = winnr()

    if g:marks_popup

        let bufnr = bufnr(s:bufname)
        if bufnr == -1
            let bufnr = nvim_create_buf(0, 0)
            call nvim_buf_set_name(bufnr, s:bufname)
        end

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
            \ 'border': g:marks_popup_border,
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

    call setwinvar(winnr, '&cursorline', g:marks_cursorline)
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

    call setbufvar(bufnr, '&filetype', 'marks')
    call setbufvar(bufnr, '&buftype', 'nofile')
    call setbufvar(bufnr, '&bufhidden', 'hide')
    call setbufvar(bufnr, '&buflisted', 0)

    let table = s:render(winid, bufnr, marks)

    let ctx = #{
        \ winid: winid,
        \ bufnr: bufnr,
        \ table: table,
        \ curr_bufnr: curr_bufnr,
        \ curr_winnr: curr_winnr,
        \ selected: 1,
        \ action: '',
    \ }

    " position the cursor to the current buffer
    let current_file = fnamemodify(bufname('%'), ':p')
    for [line, m] in items(table)
        if type(m) == v:t_string && m ==# current_file
            let ctx.selected = line
            break
        end
    endfor

    call s:setup_mappings(g:marks_mappings, ctx)
    call s:resize_window(ctx, g:marks_maxheight)

    " wipe any message
    echo

endf


" Execute the given action.
"
" Args:
"   - action (string): the action to perform
"   - ctx (dict): context info

func s:do_action(action, ctx) abort
    let a:ctx.action = a:action
    if a:action =~ '\v^(jump|tab|split|vsplit)$'
        return s:mark_jump(a:ctx)
    elseif a:action == 'delete'
        return s:mark_del(a:ctx)
    elseif a:action == 'quit'
        return 1
    else
        call s:err("Unknown action: " . a:action)
    end
endf


" Setup mappings from the current window.
"
" Args:
"  - ctx (dict): context info containing mappings
"
func s:setup_mappings(mappings, ctx) abort

    let ctx = a:ctx
    func! s:_do(action) closure abort
        let _ctx = extend(ctx, #{selected: line('.')})
        if s:do_action(a:action, _ctx)
            call win_execute(bufwinid(a:ctx.bufnr), 'close')
        end
    endf

    func! s:_nnoremap(lhs, rhs) abort
        exec "nnoremap" "<nowait> <silent> <buffer>" a:lhs a:rhs . "<cr>"
    endf

    mapclear <buffer>

    for [char, action] in items(a:mappings)
        if char =~ '\v^\\'
            let char = char[1:]
        end
        if action =~ '\v^\@'
            call s:_nnoremap(char, ":call <sid>_do('".action[1:]."')")
        elseif action =~ '\v^:'
            call s:_nnoremap(char, action)
        end
    endfo

endf


" Render marks in the given buffer.
"
" Args:
"  - winid (number): the window id
"  - bufnr (number): the buffer number where rendering needs to happen
"  - marks (dict): marks to be rendered
"
" Returns:
"   - table (dict): a dictionary that maps buffer lines to marks
"
func s:render(winid, bufnr, marks) abort

    let pipes = ['├', '└', '─']

    call clearmatches(a:winid)
    call setbufvar(a:bufnr, "&modifiable", 1)
    sil! call deletebufline(a:bufnr, 1, "$")

    if empty(a:marks)
        call setbufline(a:bufnr, 1, "No marks set")
        return {}
    end

    let fmtmark = g:marks_mark_format
    let fmtfile = g:marks_file_format

    let table = {}
    let i = 1

    for [path, marks] in items(s:group_by_file(a:marks))

        let table[i] = path
        let repl = #{file: s:prettify_path(path)}
        let [line, positions] = util#fmt(fmtfile, repl, 1)
        call setbufline(a:bufnr, i, line)
        call s:set_matches(a:winid, i, positions, g:marks_highlight)

        let i += 1
        let k = 0

        let ln_width = len(max(map(copy(marks), {k, v -> v.linenr})))
        let col_width = len(max(map(copy(marks), {k, v -> v.colnr})))

        for mark in sort(marks, {a, b -> a.linenr - b.linenr})
            let table[i] = mark
            let repl = #{
                \ pipes: k == len(marks)-1 ? pipes[1].pipes[2] : pipes[0].pipes[2],
                \ mark: mark.letter,
                \ linenr: printf('%'.ln_width.'S', mark.linenr),
                \ colnr: printf('%'.col_width.'S', mark.colnr),
                \ line: printf('%s', trim(mark.line)),
            \ }
            let [line, positions] = util#fmt(fmtmark, repl, 1)
            call setbufline(a:bufnr, i, line)
            call s:set_matches(a:winid, i, positions, g:marks_highlight)

            let i += 1
            let k += 1
        endfo

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


" Jump to the selected mark.
"
" Args:
"  - ctx (dict): context info
"
func s:mark_jump(ctx) abort

    let mark = s:get_selected_mark(a:ctx)
    if empty(mark)
        return 0
    end

    exec a:ctx.curr_winnr . 'wincmd w'
    sil! exec bufwinnr(a:ctx.bufnr) . 'wincmd c'

    if a:ctx.action =~ '\vv?split$'
        exec a:ctx.action
    elseif a:ctx.action == 'tab'
        exec 'tab split'
    end

    try
        if type(mark) == v:t_string
            exec 'buffer' bufnr(mark)
        else
            exec 'norm! `' . mark.letter
        end
    catch /.*/
        echoerr v:exception
        return 0
    finally
        norm! zz
    endtry

    return 1
endf


" Delete the selected mark.
"
" Args:
"  - ctx (dict): context info
"
func s:mark_del(ctx) abort

    let mark = s:get_selected_mark(a:ctx)
    if empty(mark) || type(mark) == v:t_string
        return 0
    end

    let cmd = 'delmarks ' .. mark.letter
    call win_execute(bufwinid(a:ctx.curr_bufnr), cmd)

    let marks = s:get_marks(a:ctx.curr_bufnr)
    let a:ctx.table = s:render(a:ctx.winid, a:ctx.bufnr, marks)
    call s:resize_window(a:ctx, g:marks_maxheight)

    return 0
endf


" Return all [a-zA-Z] marks.
"
" Returns:
"   - marks (dict): all defined marks
"
func s:get_marks(bufnr) abort
    let winid = bufwinid(a:bufnr)
    if winid == -1
        call s:err("Buffer not visible: " .. a:bufnr)
        return {}
    end
    let marks = {}
    for line in split(win_execute(winid, 'marks'), "\n")[1:]
        let match = matchlist(line, '\v\s([a-zA-Z])\s+(\d+)\s+(\d+)\s+(.*)')
        if empty(match)
            continue
        end
        let mark = #{letter: match[1], linenr: str2nr(match[2]), colnr: str2nr(match[3])}
        let path = fnamemodify(match[4], ':p')
        let mark.file = filereadable(path) ? path : fnamemodify(bufname(a:bufnr), ':p')
        let mark.line = get(getbufline(mark.file, mark.linenr), 0, '')
        let marks[match[1]] = mark
    endfo
    return marks
endf


" Group marks by the file they belong to.
"
" Args:
"   - marks (dict): marks to be grouped
"
" Returns:
"   - marks (dict): marks grouped by file
"
func s:group_by_file(marks) abort
    let groups = {}
    for mark in values(a:marks)
        if !has_key(groups, mark.file)
            let groups[mark.file] = []
        end
        call add(groups[mark.file], mark)
    endfo
    return groups
endf


" Resize the current window.
"
" Args:
"   - ctx (dict): context info
"   - max_height (number): the maximum window height as apercentage of the Vim
"   window total height
"
func s:resize_window(ctx, max_height) abort

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


" Returns the currently selected mark.
"
" Args:
"   - ctx (dict): context info
"
" Returns:
"   - mark (dict): the selected mark or and empty dictionary
"
func s:get_selected_mark(ctx)
    return get(a:ctx.table, string(a:ctx.selected), {})
endf


" Prettify the given path.
" Wherever possible, trim the current working directory.
"
" Args:
"   - path (string): the path to prettify
"
" Returns:
"   - path (string): the prettified path
"
func s:prettify_path(path) abort
    let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
    return substitute(path, '\V\^'.$HOME, '~', '')
endf


" Show a simple error message.
"
func s:err(fmt, ...) abort
    echohl WarningMsg | echom call('printf', [a:fmt] + a:000)  | echohl None
endf
