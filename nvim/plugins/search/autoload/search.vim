
let s:search = {}
let s:bufname = "__search__"

" search#do({pattern:string}, {options:dict}) -> 0
" Search for {pattern} in the current buffer.
" The {options} dictionary allows to override default global options.
func! search#do(pattern, options) abort

    let context = #{
        \ curr_line: line('.'),
        \ curr_bufnr: bufnr('%'),
        \ curr_filetype: &filetype,
    \ }

    if bufname("%") == s:bufname
        return
    end

    if empty(a:pattern)
        " Display previous search results when no pattern is given
        if bufexists(s:bufname)
            let s = getbufvar(bufnr(s:bufname), 'search').s
            if !s.do()
                call s:err("Nothing found")
            else
                let bufnr = s.open_window()
                let s.ctx.curr_line = context.curr_line
                call s.render(bufnr)
            end
        else
            call s:err("No previous searches")
        end
        return
    end

    let options = extend(_search_global_options(), a:options, 'force')
    let s = s:search.new(context, a:pattern, options)
    if !s.do()
        return s:err("Nothing found")
    end

    let bufnr = s.open_window()
    call setbufvar(bufnr, 'search', {'s': s})
    call s.render(bufnr)

endf

" s:search.open_window() -> number
" Open search buffer window or popup and return the buffer number.
func! s:search.open_window() abort

    if has('nvim') && self.options.popup

        let bufnr = bufnr(self.bufname)
        if bufnr == -1
            let bufnr = nvim_create_buf(0, 0)
            call nvim_buf_set_name(bufnr, self.bufname)
        end

        let lines = &lines - 2
        let columns = &columns - 2

        if type(self.options.width_popup) == v:t_string
            let percent = str2nr(trim(self.options.width_popup, '%'))
            let width = float2nr(columns * percent / 100)
        else
            throw "Invalid type for option width_popup: " . self.options.width_popup
        end

        if type(self.options.max_height_popup) == v:t_string
            let max_height = lines * str2nr(trim(self.options.max_height_popup, '%')) / 100
            let height = min([len(self.matches), max_height])
        else
            throw "Invalid type for option max_height_popup: " . self.options.max_height_popup
        end

        let opts = {
            \ 'relative': 'editor',
            \ 'width': width,
            \ 'height': height,
            \ 'col': (columns/2) - (width/2),
            \ 'row': float2nr((lines/2) - (height/2)) - 1,
            \ 'anchor': 'NW',
            \ 'style': 'minimal',
            \ 'border': self.options.popup_borders,
        \ }

        call nvim_open_win(bufnr, 1, opts)
        let winnr = bufwinnr(bufnr)

    else

        exec 'sil keepj keepa botright 2new' self.bufname
        let bufnr = bufnr(self.bufname)
        let winnr = bufwinnr(bufnr)
        call bufload(bufnr)

        if type(self.options.max_height_window) == v:t_string
            let max_height = lines * str2nr(trim(self.options.max_height_window, '%')) / 100
            exec "resize" min([len(self.matches), max_height])
        else
            throw "Invalid type for option max_height_window: " . self.options.max_height_window
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

" s:search.new({context:dict}, {pattern:string}, {options:dict}) -> dict
" Create a new search object.
func! s:search.new(context, pattern, options)
    let s = copy(s:search)
    let s.ctx = a:context
    let s.pattern = a:pattern
    let s.bufname = s:bufname
    let s.options = a:options
    let s.matches = []
    return s
endf

" s:search.do() -> number
" Search for {self.pattern} in {self.ctx.curr_bufnr}.
" Filtering by syntax require the current buffer to be equal to {self.ctx.curr_bufnr}.
" A number is returned to indicate success (1) or failure (0).
func! s:search.do() abort
    let self.matches = []
    let lines = getbufline(self.ctx.curr_bufnr, 1, '$')
    let exclude_syntax = {}
    if bufnr('%') == self.ctx.curr_bufnr
        let exclude_syntax = s:list2dict(self.options.exclude_syntax)
    else
        call s:err(printf("Current buffer is %s, filtering by syntax not available", bufnr('%')))
    end
    let Filter = self.options.filter_cb
    for i in range(0, len(lines)-1)
        let match = matchstrpos(lines[i], self.pattern)
        if empty(match[0]) || (Filter != v:null && !Filter(lines[i]))
            continue
        end
        if !empty(exclude_syntax) && has_key(exclude_syntax, s:synat(i+1, match[1]+1))
            continue
        end
        call add(self.matches, [i+1, match[1]+1])
    endfo
    if empty(self.matches)
        return 0
    end
    if self.options.set_search_register
        let @/ = self.pattern
    end
    if self.options.add_to_search_history
        call histadd('/', self.pattern)
    end
    return 1
endf

" s:search.render({bufnr:number}) -> 0
" Render search results in the current buffer.
func! s:search.render(bufnr, ...) abort

    let winid = bufwinid(a:bufnr)
    call setbufvar(a:bufnr, "&syntax", self.ctx.curr_filetype)
    call setbufvar(a:bufnr, "&modifiable", 1)
    call setbufvar(a:bufnr, "&list", 0)
    sil! call deletebufline(a:bufnr, 1, "$")
    call clearmatches(winid)

    let b:search.table = {}
    let width = len(self.matches[-1][0])
    let closest = self.matches[0]
    let mindist = 99999
    let padding = self.options.left_padding

    for i in range(len(self.matches))
        let m = self.matches[i]
        let b:search.table[i+1] = m

        let num = printf("%".width."s", m[0])
        let line = self.options.show_line_numbers ? num . padding : padding
        let line .= getbufline(self.ctx.curr_bufnr, m[0])[0]
        let Transform = self.options.transform_cb
        let line = Transform != v:null ? Transform(line) : line
        call setbufline(a:bufnr, i+1, line)

        let dist =abs(self.ctx.curr_line - m[0])
        if dist < mindist
            let mindist = dist
            let closest = i+1
        end
    endfor

    call self.set_statusline()

    if self.options.show_line_numbers
        call matchadd(self.options.linenr_hl, '\v^\s*\d+', -1, -1, #{window: winid})
    end

    let goto_line_number = a:0 > 0 ? a:1 : -1

    if goto_line_number > 0
        call cursor(goto_line_number, 1)
    elseif self.options.goto_closest_match
        call cursor(closest, 1)
        if closest < (len(self.matches) - (&lines / 2))
            " don't trigger zz towards the end of the list
            norm! zz
        end
    else
        call cursor(1, 1)
    end

    if self.options.show_match
        let pattern = self.pattern
        if self.options.show_line_numbers
            " match only after the line number column
            let pattern = '\%>' . (width+len(padding)) . 'c' . self.pattern
        end
        call matchadd(self.options.match_hl, pattern, -1, -1, #{window: winid})
    end

    call setbufvar(a:bufnr, "&modifiable", 0)
endf

" s:search.set_statusline() -> 0
" Set the statusline with the current search info.
func! s:search.set_statusline()
    let bufname = join(split(fnamemodify(bufname(self.ctx.curr_bufnr), ':p:~'), '/')[-1:], '/')
    let exclude_syntax = self.options.exclude_syntax
    let exclude = empty(exclude_syntax) ? "" : " exclude=[" . join(exclude_syntax, ', ') . "]"
    call setwinvar(0, '&stl', printf(' search /%s/%s %s', self.pattern, exclude, bufname))
endf

" s:setup_mappings() -> 0
" Setup mappings for the search results window
func! s:setup_mappings()
    for trigger in g:search_mappings_jump
        exec 'nnoremap <silent> <buffer>' trigger ':call <sid>jump()<cr>'
    endfor
    for trigger in g:search_mappings_close
        exec 'nnoremap <silent> <buffer>' trigger ':close<cr>'
    endfor
    for trigger in g:search_mappings_context
        exec 'nnoremap <silent> <buffer>' trigger ':<c-u>call <sid>show_context()<cr>'
    endfor
    for trigger in g:search_mappings_toggle_numbers
        exec 'nnoremap <silent> <buffer>' trigger ':call <sid>toggle_numbers()<cr>'
    endfor
endf

" s:jump() -> 0
" Jump to the current search result
func! s:jump()
    let bufnr = b:search.s.ctx.curr_bufnr
    let entry = get(b:search.table, line('.'), [])
    if empty(entry)
        return
    end
    close
    norm! m'
    exec bufnr 'buffer'
    call cursor(entry)
    norm! zz
endf

" s:show_context() -> 0
" Show context lines for the search result under cursor
func! s:show_context()
    let bufnr = b:search.s.ctx.curr_bufnr
    let entry = get(b:search.table, line('.'), [])
    if empty(entry)
        return
    end
    let start = max([entry[0] - v:count1, 1])
    let end = entry[0] + v:count1
    echo join(getbufline(bufnr, start, end), "\n")
endf

" s:toggle_numbers() -> 0
" Toggle numbers visibility
func! s:toggle_numbers()
    let b:search.s.options.show_line_numbers = 1 - b:search.s.options.show_line_numbers
    call b:search.s.render(bufnr('%'), line('.'))
endf

" s:synat({line:number}, {col:number}) -> string
" Return the syntax group at the given position.
func! s:synat(line, col)
    return synIDattr(synIDtrans(synID(a:line, a:col, 0)), 'name')
endf

" s:list2dict({list:list}[, {fn:funcref}]) -> dict
" Construct a dictionary from a list.
" If a function {fn} is given, then to every dictionary key 'item' will
" be associated the value returned from fn(item). If {fn} is not given, the
" value 1 is used instead.
func! s:list2dict(list, ...)
    let dict = {}
    let Fn = a:0 > 0 && type(a:1) == t:v_func ? a:1 : {-> 1}
    for item in a:list
        if !has_key(dict, item)
            let dict[item] = Fn(item)
        end
    endfo
    return dict
endf

" s:err({msg:string}) -> 0
" Display a simple error message.
func! s:err(msg)
    echohl WarningMsg | echo a:msg | echohl None
endf
