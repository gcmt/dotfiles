
" INIT
" ----------------------------------------------------------------------------

    let $VIMHOME = $HOME . '/.config/nvim'

    if !exists('$VIMCACHE')
        let $VIMCACHE = $HOME . '/.cache/nvim'
    end
    if !exists('$VIMDATA')
        let $VIMDATA = $HOME . '/.local/share/nvim'
    end

    let g:plugins = []
    call add(g:plugins, $VIMHOME.'/plugins/marks')
    call add(g:plugins, $VIMHOME.'/plugins/bookmarks')
    call add(g:plugins, $VIMHOME.'/plugins/buffers')
    call add(g:plugins, $VIMHOME.'/plugins/commenter')
    call add(g:plugins, $VIMHOME.'/plugins/explorer')
    call add(g:plugins, $VIMHOME.'/plugins/finder')
    call add(g:plugins, $VIMHOME.'/plugins/objects')
    call add(g:plugins, $VIMHOME.'/plugins/grep')
    call add(g:plugins, $VIMHOME.'/plugins/quickfix')
    call add(g:plugins, $VIMHOME.'/plugins/regtee')
    call add(g:plugins, $VIMHOME.'/plugins/search')
    call add(g:plugins, $VIMHOME.'/plugins/spotter')
    call add(g:plugins, $VIMHOME.'/plugins/fm')
    call add(g:plugins, $VIMHOME.'/plugins/fzf')

    let g:vendor = []
    call add(g:vendor, $VIMDATA.'/vendor/nvim-treesitter')
    call add(g:vendor, $VIMDATA.'/vendor/vim-fugitive')
    call add(g:vendor, $VIMDATA.'/vendor/vim-gitgutter')
    call add(g:vendor, $VIMDATA.'/vendor/UltiSnips')
    call add(g:vendor, $VIMDATA.'/vendor/editorconfig-vim')
    call add(g:vendor, $VIMDATA.'/vendor/vim-go')
    call add(g:vendor, $VIMDATA.'/vendor/ale')

    let s:rtp = []
    call extend(s:rtp, g:plugins + g:vendor)
    call extend(s:rtp, globpath(join(g:plugins, ','), 'after', 1, 1))
    call extend(s:rtp, globpath(join(g:vendor, ','), 'after', 1, 1))
    exec 'set rtp+=' . join(s:rtp, ',')

" OPTIONS
" ----------------------------------------------------------------------------

    filetype plugin indent on

    if empty($VIMCACHE)
        set viminfo=
        set noundofile
    else
        set viminfo=!,'100,f0
        set viminfofile=$VIMCACHE/viminfo
        set undofile
        set undodir=$VIMCACHE/undo
    end

    set directory=
    set noswapfile

    set spelllang=it,en
    set updatetime=300
    set timeoutlen=1000
    set ttimeoutlen=10
    set lazyredraw
    set path=**

    set ignorecase
    set smartcase
    set showmatch
    set nohlsearch

    set clipboard=

    let mapleader = "\<space>"

    func! s:get_term_bg()
        let bg = matchstr(system('xrdb -query all'), '\v<colorscheme.name:\s+\zs\w+')
        return empty(bg) ? 'dark' : bg
    endf

    func! s:set_bg(bg)
        let &background = a:bg
        exec 'sil!' '!colorscheme' a:bg
        redraw!
    endf

    command! Dark call <sid>set_bg("dark")
    command! Light call <sid>set_bg("light")
    command! Minimal let g:minimal = 1 - g:minimal<bar>let &bg = &bg

    let g:minimal = 1
    let &bg = s:get_term_bg()
    colorscheme main

    set cmdheight=1
    set laststatus=3

    set guioptions=c

    let &guifont = 'Noto Mono Patched 10'
    set linespace=1

    set title
    let &titlestring = "%{getcwd()} - Vim"

    set nowrap
    set linebreak
    set breakindent
    set showbreak=..
    set textwidth=80

    set number
    set norelativenumber
    set numberwidth=1
    set nocursorline

    set scrolloff=0
    set sidescrolloff=0

    set virtualedit=block

    set expandtab
    set tabstop=4
    set shiftwidth=0
    set softtabstop=0

    set wildmode=full
    set wildignore+=
    set wildignore+=*/venv/*,venv$
    set wildignore+=*/__pycache__/*,__pycache__
    set wildignore+=*/node_modules/*,node_modules
    set wildignore+=.git,.DS_Store,tags,.tags,*.retry
    set wildignore+=*.sqlite3,*.pyc,*.beam,*.so
    set wildignore+=*.jpg,*.jpeg,*.png,*.ico,*.gif

    set formatoptions=crq1nj
    set nrformats-=octal

    set splitbelow
    set splitright

    set nofoldenable
    set foldcolumn=0

    set completeopt=menuone,longest
    set report=9999
    set shortmess=CFFOIAoastc
    set noshowmode
    set visualbell
    set t_vb=

    set list
    let g:listchars = ',leadmultispace:│   ,trail:·,precedes:‹,extends:›'
    let &listchars = 'tab:  ' . listchars

" STATUSLINE
" ----------------------------------------------------------------------------

    func! _stl_buffer(win, sep)
        let bnum = a:win.bufnr
        let bname = bufname(bnum)
        let bt = getbufvar(bnum, '&buftype')
        let ft = getbufvar(bnum, '&filetype')
        let flags = ''
        if !empty(bt)
            let flags .= '[' . bt . ']'
        end
        if getbufvar(bnum, '&previewwindow')
            let flags .= '[preview]'
        end
        if getbufvar(bnum, '&readonly')
            let flags .= '[ro]'
        end
        let name = ''
        if empty(bname)
            let name = '[no name]'
        elseif !empty(bt) || ft == 'notes'
            let name = fnamemodify(bname, ':t')
        else
            if winwidth(a:win.winid) < 60
                let name = fnamemodify(bname, ':t')
            elseif winwidth(a:win.winid) > 100
                let name = fnamemodify(bname, ':p')
                let name = substitute(name, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
                let name = substitute(name, '\V\^'.$HOME, '~', '')
            else
                let name = join(split(fnamemodify(bname, ':p:~'), '/')[-2:], '/')
            end
        end
        if getbufvar(bnum, '&modified')
            let name = name . ' [+]'
        end
        if !empty(flags)
            let name = '%#StatusLineDim#' . flags . '%*' . a:sep . name
        end
        return name
    endf

    func! _stl_alternate(win)
        if win_getid() != a:win.winid
            return ''
        end
        let bnum = a:win.bufnr
        let bname = bufname(bnum)
        let alt = expand('#:t')
        if !empty(alt) && expand('#:p') != fnamemodify(bname, ':p') && a:win.width > 80
            return '%#StatusLineDim#[' . alt . ']%*'
        end
        return ''
    endf

    func! _stl_flags(win)
        if a:win.width < 80
            return []
        end
        let flags = []
        if !empty(getqflist())
            call add(flags, '[QF]')
        end
        if !empty(getloclist(a:win.winid))
            call add(flags, '[LOC]')
        end
        return join(flags, ' ')
    endf

    func! _stl_meta(win, sep)
        let items = []
        let bnum = a:win.bufnr
        let diff = getbufvar(bnum, '&diff')
        let bt = getbufvar(bnum, '&buftype')
        let ft = getbufvar(bnum, '&filetype')
        let ff = getbufvar(bnum, '&fileformat')
        let fenc = getbufvar(bnum, '&fileencoding')
        let enc = getbufvar(bnum, '&encoding')
        let enc = printf('%s:%s', fenc ? fenc : enc, ff)
        if !empty(ft) && empty(bt) && a:win.width > 80
            if !diff && ft == 'python' && !empty($VIRTUAL_ENV) && a:win.width > 60
                let venv = fnamemodify($VIRTUAL_ENV, ':t')
                let ft .= '@' . venv
            end
            call add(items, ft)
        end
        call filter(items, 'len(v:val)')
        return join(items, a:sep)
    endf

    func! _stl_branch(win)
        if win_getid() != a:win.winid
            return ''
        end
        let bnum = a:win.bufnr
        let diff = getbufvar(bnum, '&diff')
        let branch = exists('*FugitiveHead') ? FugitiveHead() : ''
        if !diff && !empty(branch) && a:win.width > 60
            return 'git@' . branch
        end
        return ''
    endf

    func! _stl_venv(win)
        let bnum = a:win.bufnr
        let diff = getbufvar(bnum, '&diff')
        if !diff && &ft == 'python' && !empty($VIRTUAL_ENV) && a:win.width > 60
            return 'venv:' . fnamemodify($VIRTUAL_ENV, ':t')
        end
        return ''
    endf

    func! _stl_clip(win)
        if !empty(&clipboard) && a:win.width > 60
            return 'clip:' . substitute(&clipboard, '\vplus$', '+', '')
        end
        return ''
    endf

    func! _stl_regtee()
        let reg = get(g:, 'regtee_register', '')
        if empty(reg)
            return ''
        end
        let lines = len(getreg(reg)) ? len(getreg(reg, 1, 1)) : 0
        let chars = strchars(getreg(reg))
        return printf("@%s|%dL|%dc", reg, lines, chars)
    endf

    func! _stl_mode(win)
        let map = {'n': 'normal', 'v': 'visual', 'V': 'visual', 'i': 'insert', 'c': 'cmd'}
        return toupper('--'.get(map, mode(), mode()).'--')
    endf

    fun! _stl_ale(win)
        try
            let counts = ale#statusline#Count(a:win.bufnr)
        catch /.*/
            return ''
        endtry
        let errors = counts.error + counts.style_error
        let warnings = counts.total - errors
        if counts.total
            let ret = '['
            let ret .= warnings ? warnings . 'W' : ''
            let ret .= warnings && errors ?  '/' : ''
            let ret .= errors ? errors . 'E' : ''
            let ret .= ']'
            return ret
        end
        return ''
    endf

    func! _stl()
        let ret = ''
        let win = getwininfo(g:statusline_winid)[0]
        let sep = win.width < 110 ? '  ' : '   '
        try
            let items = []
            call add(items, _stl_alternate(win))
            call add(items, _stl_buffer(win, sep))
            call add(items, '%=')
            call add(items, _stl_regtee())
            call add(items, _stl_clip(win))
            call add(items, _stl_ale(win))
            call add(items, _stl_branch(win))
            call add(items, _stl_meta(win, sep))
            call add(items, '%1lL %02cC (%P)')
            call add(items, _stl_flags(win))
            call filter(items, {_, v -> !empty(v)})
            return ' ' . join(items, sep) . ' '
        catch /.*/
            return matchstr(v:exception, '\vE\d+:.*')
        endtry
    endf

    set stl=%!_stl()

" TABS
" ----------------------------------------------------------------------------

    set tabline=%!_tabline()

    func! _tabline()
        let tabline = ''
        for tabnr in range(1, tabpagenr('$'))
            let tabline .= tabnr == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'
            let tabline .= ' %' . tabnr . 'T'
            let tabname = gettabvar(tabnr, 'tabname', '')
            let tabname = empty(tabname) ? 'TAB' : tabname
            let tabline .= printf('[ #%s %s ]', tabnr, tabname)
            let tabline .= ' '
        endfor
        let tabline .= '%#TabLineFill#%T'
        let tabline .= '%=%#TabLine#%999X'
        return tabline
    endf

    command! -nargs=? Tab tabe | TabName <args>
    command! -nargs=? TabName call <sid>set_tabname(<q-args>)

    func! s:set_tabname(name)
        let t:tabname = a:name
        set tabline=%!_tabline()
    endf

    " when there is only one tab, open a new one
    nnoremap <silent> <expr> gt tabpagenr('$') == 1 ? ':$tab split<cr>' : '<c-u>:norm! '.v:count.'gt<cr>'
    nnoremap <silent> <expr> gT tabpagenr('$') == 1 ? ':0tab split<cr>' : '<c-u>:norm! '.v:count.'gT<cr>'

" WINDOWS
" ----------------------------------------------------------------------------

    aug _windows
        au!
        au VimResized * wincmd = | redraw
    aug END

    " view current buffer in a new tab
    nnoremap <c-w>t :tabe %<cr>
    tnoremap <c-w>t <c-w>:tabe %<cr>

    nnoremap <silent> <c-w>v <c-w>v:b#<cr>
    nnoremap <silent> <c-w>s <c-w>s:b#<cr>

    nnoremap <silent> <left> <c-w>h
    nnoremap <silent> <right> <c-w>l
    nnoremap <silent> <up> <c-w>k
    nnoremap <silent> <down> <c-w>j

" BUFFERS
" ----------------------------------------------------------------------------

    aug _buffers
        au!
        au BufReadPost * call setpos(".", getpos("'\""))
    aug END

    " switch to the alternate buffer
    nnoremap <silent> <tab> :call <sid>goto_alternate()<cr>

    func! s:goto_alternate()
        if buflisted(@#)
            buffer #
        elseif !empty(@#)
            call util#err("The alternate buffer has been unlisted")
        else
            call util#err("No alternate buffer")
        end
    endf

    command! -bang -nargs=0 Bdelete call util#bdelete('bdelete', <q-bang>)
    nnoremap <silent> <c-w>d :Bdelete!<cr>

" EDITING
" ----------------------------------------------------------------------------

    inoremap <c-e> <c-g>u<esc>O
    inoremap <c-d> <c-g>u<esc>o
    inoremap <c-w> <c-g>u<c-w>
    inoremap <c-l> <right><bs>
    cnoremap <c-l> <right><bs>

    " create empty lines without leaving normal mode
    nnoremap <silent> <c-e> :<c-u>call append(line('.')-1, map(range(v:count1), "''"))<cr>
    nnoremap <silent> <c-d> :<c-u>call append(line('.'), map(range(v:count1), "''"))<cr>

    " buffer text object
    vnoremap a% G$ogg
    onoremap a% :<c-u>norm va%<cr>

    " blackhole register shortcut
    nnoremap _ "_
    vnoremap _ "_

    " + register shortcut
    nnoremap + "+
    vnoremap + "+

    " select the last changed text
    nnoremap <expr> gV '`[' . strpart(getregtype(), 0, 1) . '`]'

    nmap g= gV=

    nmap <silent> ]P Pg=gqac
    nmap <silent> ]p pg=gqac

    " replace selection without side effects
    vmap <expr> P '_d"' . v:register . 'P'
    vmap <expr> ]P '_d"' . v:register . ']P'

    " toggle paste
    nnoremap gop :set paste!<bar>set paste?<cr>

    " copy to the end of the line
    nnoremap Y y$

    " indent lines without losing selection
    vnoremap < <gv
    vnoremap > >gv

" MOVING AROUND
" ----------------------------------------------------------------------------

    nnoremap ' `

    nnoremap <c-u> <c-e>

    inoremap <c-g>l <esc>la
    inoremap <c-g><c-l> <esc>la
    inoremap <c-g>h <esc>ha
    inoremap <c-g><c-h> <esc>ha

    noremap j gj
    noremap k gk

    noremap J 3gj
    noremap K 3gk

    noremap <c-j> 5<c-e>
    noremap <c-k> 5<c-y>

    " jump after given characters without leaving insert mode
    inoremap <silent> <c-f> <c-r>=_jump_after("\\v[])}>`\"']", 1)<cr>
    inoremap <silent> <c-t> <c-r>=_jump_after("}", 0)<cr>

    func! _jump_after(pattern, sameline = 0)
        let pos = searchpos(a:pattern, 'Wcen')
        if pos == [0, 0] || a:sameline && pos[0] != line('.')
            return ''
        end
        call cursor(pos)
        return "\<right>"
    endf

" SEARCH AND SUBSTITUTE
" ---------------------------------------------------------------------------

    aug _hlsearch
        au!
        if exists("##CmdlineEnter")
            au CmdlineEnter [/\?] set hlsearch
            au CmdlineLeave [/\?] set nohlsearch
        end
    aug END

    " use <tab> and <s-tab> instead of <c-g> and <c-t>
    cnoremap <expr> <tab> getcmdtype() =~ '[?/]' ? '<c-g>' : feedkeys('<tab>', 'int')[1]
    cnoremap <expr> <s-tab> getcmdtype() =~ '[?/]' ? '<c-t>' : feedkeys('<s-tab>', 'int')[1]

    " toggle highlighting of the last search pattern
    nnoremap <silent> <c-h> :set hlsearch!<bar>set hlsearch?<cr>

    " Toggle search for current word or selected text without moving the cursor
    nnoremap <silent> \ :call util#search(0)<cr>
    vnoremap <silent> \ :<c-u>call util#search(1)<cr>
    nnoremap <silent> <RightMouse> <LeftMouse>:call util#search(0)<cr>
    vnoremap <silent> <RightMouse> :<c-u>call util#search(1)<cr>

" YANK FEEDBACK
" ----------------------------------------------------------------------------

    aug _yankhl
        au!
        if exists("##TextYankPost") && has('timers')
            au TextYankPost * call <sid>yankhl()
        end
    aug END

    func! s:yankhl()
        if v:event.operator != 'y' || v:event.regname == '*'
            return
        end
        let lines = v:event.regcontents
        if len(lines) > &lines*2
            return
        end
        call map(lines, {-> escape(v:val, '\\')})
        if !empty(lines) && empty(lines[-1])
            let lines[-1] = '\n'
        end
        let pattern = printf('\V\%%%dl\%%%dc%s', line("'["), col("'["), join(lines, '\n'))
        let id = matchadd("Yank", pattern, -1)
        call timer_start(350, {-> call('matchdelete', [id])})
    endf

" REGISTERS
" ----------------------------------------------------------------------------

    vnoremap @ :norm! @

    nnoremap Q @q
    vnoremap <silent> Q :norm! @q<cr>

    " edit registers
    command! -nargs=? Regedit call util#regedit(<q-args>)

    " tee yanks to a sticky register
    nnoremap <expr> gQ ":Regtee ".nr2char(getchar())."<cr>"

" MISC
" ----------------------------------------------------------------------------

    aug _misc
        au!

        au BufEnter * if isdirectory(expand('%:p')) | exec 'Explorer!' expand('%:p') | end

        au FocusGained,BufEnter,CursorHold * sil! checktime

        au BufWritePost */nvim/init.vim source $MYVIMRC
        au BufWritePost */nvim/colors/*.vim nested exec 'colorscheme' g:colors_name
        au BufWritePost */*Xresources.d/* call <sid>set_bg(&background)
        au BufWritePost */ftplugin/*.vim source % | exec 'au BufEnter ' . expand('#:p') . ' ++once let &ft = &ft'

        au CmdWinEnter * set ft=
        au CmdWinEnter * nnoremap <buffer> l <cr>
        au CmdWinEnter * noremap <buffer> <c-j> <cr>
        au CmdWinEnter * noremap <buffer> q <c-w>c
        au CmdWinEnter * setl nonumber norelativenumber
        au CmdWinEnter * resize 20 | keepj norm! ggG

        " Keep the help window to the bottom when there are multiple splits
        au BufWinEnter * if &ft == 'help' | wincmd J | end
        au BufWinEnter * if &ft == 'help' | nnoremap <silent> <buffer> q <c-w>c | end

        " Show cursorline only for a short amount of time
        "au CursorHold,CursorHoldI * if empty(&buftype) | set nocul | end

        " Filetype fixes
        au BufNewFile,BufRead *.ledger set ft=ledger
        au BufNewFile,BufRead */Xresources.d/* set ft=xdefaults
        au BufNewFile,BufRead *.rasi set ft=css
    aug END

    "inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    "inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

    " Clear undo history (:h clear-undo)
    command! -nargs=0 ClearUndo call util#clear_undo()

    command! -nargs=0 Vimrc edit $MYVIMRC
    command! -nargs=0 ColorEdit  exec 'e' $VIMHOME.'/colors/' . g:colors_name . '.vim'

	command! -nargs=? -complete=filetype Ftedit call <sid>ft_edit(<q-args>)

	func! s:ft_edit(ft)
		let ft = empty(a:ft) ? &ft : a:ft
		call finder#find($VIMHOME, 'ftplugin.*'.ft.'\.vim$', 1)
	endf

    " Write helpers
    command! -nargs=0 SudoWrite exec 'write !sudo tee % > /dev/null'
    command! -bang -nargs=* W write<bang> <args>
    command! -bang Wq wq<bang>
    command! -bang Q q<bang>

    comm -bang -nargs=0 Quit quit<bang>

    nnoremap <2-RightMouse> <nop>
    nnoremap <3-RightMouse> <nop>

    nnoremap <F2> :w<cr>
    inoremap <F2> <esc>:w<cr>

    cnoremap <c-n> <down>
    cnoremap <c-p> <up>

    inoremap <c-c> <c-]><esc>
    inoremap <c-u> <c-g>u<c-u>

    inoremap <c-a> <down>
    inoremap <c-j> <c-g>u<c->
    inoremap <cr> <c-g>u<cr>

    vnoremap C c

    noremap gj J
    noremap gk K

    iabbrev teh the
    iabbrev wiht with
    iabbrev lenght length
    iabbrev retrun return

    nnoremap <silent> gow :set wrap!<bar>set wrap?<cr>
    nnoremap <silent> gon :set number!<bar>set number?<cr>
    nnoremap <silent> goz :let &scrolloff = abs(&scrolloff - 999)<bar>set scrolloff?<cr>
    nnoremap <silent> goc :call <sid>toggle_clipboard()<cr>

    func! s:toggle_clipboard()
        if empty(&clipboard)
            set clipboard=unnamedplus
        else
            set clipboard=
        end
    endf

" QUICKFIX
" ----------------------------------------------------------------------------

	let g:quickfix_height = 50

	nnoremap <silent> ]q :cnext<cr>zz:set cul<cr>
	nnoremap <silent> ]Q :clast<cr>zz:set cul<cr>
	nnoremap <silent> [q :cprev<cr>zz:set cul<cr>
	nnoremap <silent> [Q :cfirst<cr>zz:set cul<cr>

	nnoremap <silent> ]l :lnext<cr>zz:set cul<cr>
	nnoremap <silent> ]L :llast<cr>zz:set cul<cr>
	nnoremap <silent> [l :lprev<cr>zz:set cul<cr>
	nnoremap <silent> [L :lfirst<cr>zz:set cul<cr>

" Cd
" ----------------------------------------------------------------------------

    let g:root_markers = ['.gitignore']

    command! -bang -nargs=0 Here call util#cd_into_buf_dir(<q-bang>)
    command! -bang -nargs=0 Root call util#cd_into_root_dir(<q-bang>)

" Search
" ----------------------------------------------------------------------------

    nnoremap s :Search<space>
    nnoremap gs :Search<cr>
    nnoremap <silent> S :Search \<<c-r><c-w>\><cr>

" Fzf
" ----------------------------------------------------------------------------

	nnoremap <silent> <c-f> :Files<cr>

" Buffers
" ----------------------------------------------------------------------------

    nnoremap <silent> <enter> :Buffers<cr>

" Marks
" ----------------------------------------------------------------------------

    nnoremap <silent> m, :call marks#view()<cr>
    nnoremap <silent> m. :call marks#set_auto(1)<cr>
    nnoremap <silent> m: :call marks#set_auto(0)<cr>

" Bookmarks
" ----------------------------------------------------------------------------

    nnoremap <silent> gb :call bookmarks#view()<cr>
    nnoremap <silent> <c-b> :call bookmarks#jump(getchar())<cr>
    nnoremap <silent> gm :call bookmarks#set(input("MarkFile: "), expand('%:p'))<cr>
    nnoremap <silent> gM :call bookmarks#set(input("MarkDir: "), expand('%:p:h'))<cr>

" Spotter
" ----------------------------------------------------------------------------

    let g:spotter_banned_filetypes = {
        \ 'html':1, 'jinja':1, 'htmldjango':1, "json":1,
        \ 'text':1, 'markdown':1, 'notes':1,
    \ }

    let g:spotter_banned_syntax_elixir = {
        \ 'elixirDocString':1
    \ }

    let g:spotter_banned_words_javascript = {
        \ 'var':1, 'let':1, 'const':1, 'function':1, 'class':1
    \ }

" Explorer/Ranger/Vifm
" ----------------------------------------------------------------------------

    nnoremap <silent> g. :exec 'Fm' expand('%:p')<cr>
    nnoremap <silent> <backspace> :exec 'Fm' getcwd()<cr>

    let g:explorer_filters = [{node -> node.filename() !~ '\v^(.git|node_modules|venv)$'}]

    "nnoremap <silent> <backspace> :Explorer<cr>
    "nnoremap <silent> g. :exec 'Explorer' expand('%:p')<cr>
    "nnoremap <silent> g: :exec 'Explorer' getcwd()<cr>

" GitGutter
" ----------------------------------------------------------------------------

	let g:gitgutter_enabled = 1

" Ale
" ----------------------------------------------------------------------------

    aug _ale
        au!
        au BufEnter * if !empty(&bt) | ALEDisableBuffer | end
    aug END

	highlight link AleError Underlined
	highlight link AleWarning Underlined
	highlight link AleErrorSign Red
	highlight link AleWarningSign Orange

    let g:ale_echo_msg_error_str = 'E'
    let g:ale_echo_msg_warning_str = 'W'
	let g:ale_sign_error = 'x'
	let g:ale_sign_warning = '!'
	let g:ale_lint_on_text_changed = 'never'
	let g:ale_open_list = 0
	let g:ale_fix_on_save = 1

	let g:ale_fixers = {}
	let g:ale_fixers['ledger'] = ['remove_trailing_lines', 'trim_whitespace']
	let g:ale_fixers.python = ['black']

	let g:ale_linters = {}
	let g:ale_linters.python = ['flake8', 'mypy']

	let g:ale_python_pylint_options = '--disable=C0111,C0103'
	let g:ale_python_flake8_options = '--ignore=E203,E501'
	let g:ale_sh_shellcheck_options = '-e SC2181 -e SC2155'

" Disable unused plugins
" ----------------------------------------------------------------------------

	let g:loaded_2html_plugin = 1
	let g:loaded_netrwPlugin = 1

" editor config
" ----------------------------------------------------------------------------

    let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" vim-go
" ----------------------------------------------------------------------------

    let g:go_fmt_autosave = 1
    let g:go_fmt_command = "goimports"
    let g:go_list_type = "quickfix"
    let g:go_fmt_fail_silently = 1
    let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']
    let g:go_metalinter_autosave = 1
    let g:go_metalinter_autosave_enabled = ['vet', 'golint']
    let g:go_auto_type_info = 1

" source init.lua
" ----------------------------------------------------------------------------

    lua require('init')
