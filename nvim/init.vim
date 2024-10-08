" INIT
" ----------------------------------------------------------------------------

    let $VIMHOME = $HOME . '/.config/nvim'

    if !exists('$VIMCACHE')
        let $VIMCACHE = $HOME . '/.cache/nvim'
    end
    if !exists('$VIMDATA')
        let $VIMDATA = $HOME . '/.local/share/nvim'
    end

    let $VIMVENDOR = $VIMDATA . '/vendor'

    let g:plugins = []

    call add(g:plugins, $HOME.'/Dev/vim/cmdfix.nvim')
    call add(g:plugins, $HOME.'/Dev/vim/regtee.nvim')
    call add(g:plugins, $HOME.'/Dev/vim/vessel.nvim')
    call add(g:plugins, $VIMHOME.'/plugins/bookmarks')
    call add(g:plugins, $VIMHOME.'/plugins/commenter')
    call add(g:plugins, $VIMHOME.'/plugins/explorer')
    call add(g:plugins, $VIMHOME.'/plugins/finder')
    call add(g:plugins, $VIMHOME.'/plugins/objects')
    call add(g:plugins, $VIMHOME.'/plugins/grep')
    call add(g:plugins, $VIMHOME.'/plugins/quickfix')
    call add(g:plugins, $VIMHOME.'/plugins/search')
    call add(g:plugins, $VIMHOME.'/plugins/spotter')
    call add(g:plugins, $VIMHOME.'/plugins/vifm')
    call add(g:plugins, $VIMHOME.'/plugins/fzf')

    let g:external = []

    call add(g:external, 'dense-analysis/ale')
    call add(g:external, 'L3MON4D3/LuaSnip')
    call add(g:external, 'tpope/vim-fugitive')
    call add(g:external, 'sindrets/diffview.nvim')
    call add(g:external, 'nvim-lua/plenary.nvim')
    call add(g:external, 'airblade/vim-gitgutter')
    call add(g:external, 'neovim/nvim-lspconfig')
    call add(g:external, 'nvim-treesitter/nvim-treesitter')
    call add(g:external, 'hrsh7th/nvim-cmp')
    call add(g:external, 'hrsh7th/cmp-nvim-lsp')
    call add(g:external, 'hrsh7th/cmp-nvim-lsp-signature-help')
    call add(g:external, 'hrsh7th/cmp-buffer')
    call add(g:external, 'hrsh7th/cmp-path')
    call add(g:external, 'ibhagwan/fzf-lua')

    for s:ext in g:external
        call add(g:plugins, $VIMVENDOR . '/' . split(s:ext, '/')[-1])
    endfor

    let s:rtp = []
    call extend(s:rtp, g:plugins)
    call extend(s:rtp, globpath(join(g:plugins, ','), 'after', 1, 1))
    exec 'set rtp+=' . join(s:rtp, ',')

    command -nargs=0 PlugInstall call <sid>plug_install()

    func! s:plug_install()
        for plugin in g:external
            let path = $VIMVENDOR . '/' . split(plugin, '/')[-1]
            if isdirectory(path)
                echo plugin '...' 'DIRECTORY EXISTS'
            else
                echo plugin '...' 'INSTALLING'
                call system(printf('git clone https://github.com/%s %s', plugin, shellescape(path)))
            end
        endfor
    endf

    command -nargs=0 PlugUpdate call <sid>plug_update()

    func! s:plug_update()
        for plugin in g:external
            echo plugin '...' 'UPDATING'
            let path = $VIMVENDOR . '/' . split(plugin, '/')[-1]
            call system(printf('git -C %s pull', shellescape(path)))
        endfor
    endf

" OPTIONS
" ----------------------------------------------------------------------------

    filetype plugin indent on

    if empty($VIMCACHE)
        set shada=
        set shadafile=NONE
        set noundofile
    else
        set shada=!,'50,/50,:50,s100,f1
        set shadafile=$VIMCACHE/shada
        set undofile
        set undodir=$VIMCACHE/undo
    end

    set directory=
    set noswapfile

    set notermguicolors
    set spelllang=it,en
    set updatetime=300
    set timeoutlen=1000
    set ttimeoutlen=10
    set lazyredraw
    set path=**

    set ignorecase
    set smartcase
    set noshowmatch
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
    set laststatus=2

    set guioptions=c

    let &guifont = 'Noto Mono Patched 10'
    set linespace=1

    set title
    let &titlestring = "%{getcwd()} - Vim"

    set nowrap
    set linebreak
    set breakindent
    set showbreak=>>
    set textwidth=80

    set number
    set norelativenumber
    set numberwidth=1
    set nocursorline

    set scrolloff=0
    set sidescrolloff=0
    set smoothscroll
    set mousescroll=ver:8,hor:1

    set virtualedit=block

    set expandtab
    set tabstop=4
    set shiftwidth=0
    set softtabstop=0

    set wildoptions=pum,fuzzy
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

    set completeopt=menu,menuone,noselect
    set report=9999
    set shortmess=CFFOIAoastc
    set noshowmode
    set visualbell
    set t_vb=

    set list
    let &listchars = 'tab:│  ,leadmultispace:│   ,trail:·,precedes:‹,extends:›'

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
        if win_getid() == a:win.winid
            let name = '%#StatusLineBold#' . name . '%*'
        end
        if getbufvar(bnum, '&modified')
            let name = name . a:sep . '[+]'
        end
        if !empty(flags)
            let name = flags . a:sep . name
        end
        return name
    endf

    func! STLGotoAltBuffer(minwid, clicks, btn, mod)
        call s:goto_alternate()
    endf

    func! _stl_alternate(win)
        if win_getid() != a:win.winid || a:win.width < 80
            return ''
        end
        let alt = expand('#:t')
        if !empty(alt) && buflisted(@#) && expand('#:p') != fnamemodify(bufname(a:win.bufnr), ':p')
            return '%@STLGotoAltBuffer@' . alt . '%X'
        end
        return ''
    endf

    func! STLOpenQuickfix(minwid, clicks, btn, mod)
        copen
    endf

    func! STLOpenLoclist(minwid, clicks, btn, mod)
        lopen
    endf

    func! _stl_qf(win)
        if a:win.width < 80
            return []
        end
        let flags = []
        let qlist = getqflist()
        if !empty(qlist)
            call add(flags, '%@STLOpenQuickfix@qf = '.len(qlist).'%X')
        end
        let llist = getloclist(a:win.winid)
        if !empty(llist) && win_getid() == a:win.winid
            call add(flags, '%@STLOpenLoclist@loc = '.len(llist).'%X')
        end
        return join(flags, ', ')
    endf

    func! _stl_meta(win)
        let bnum = a:win.bufnr
        let diff = getbufvar(bnum, '&diff')
        let bt = getbufvar(bnum, '&buftype')
        let ft = getbufvar(bnum, '&filetype')
        let ff = getbufvar(bnum, '&fileformat')
        let fenc = getbufvar(bnum, '&fileencoding')
        let enc = getbufvar(bnum, '&encoding')
        let enc = printf('%s:%s', fenc ? fenc : enc, ff)
        let items = [ft]
        if a:win.width > 120
            call add(items, enc)
        end
        call filter(items, 'len(v:val)')
        return join(items, ', ')
    endf

    func! _stl_venv(win)
        let diff = getbufvar(a:win.bufnr, '&diff')
        let bt = getbufvar(a:win.bufnr, '&buftype')
        let ft = getbufvar(a:win.bufnr, '&filetype')
        if !empty(ft) && empty(bt) && a:win.width > 80
            if !diff && ft == 'python' && !empty($VIRTUAL_ENV)
                let venv = fnamemodify($VIRTUAL_ENV, ':t')
                return 'py = ' . venv
            end
        end
        return ''
    endf

    func! _stl_git_status(win)
        if win_getid() != a:win.winid || !exists('*GitGutterGetHunkSummary')
            return ''
        end
        let [a, m, r] = GitGutterGetHunkSummary()
        let branch = _stl_git_branch(a:win)
        if !getbufvar(a:win.bufnr, '&diff') && !empty(branch) && a:win.width > 60
            return printf('+%d ~%d -%d @ %s', a, m, r, branch)
        end
        return ''
    endf

    func! _stl_git_branch(win)
        if win_getid() != a:win.winid || !exists('*FugitiveHead')
            return ''
        end
        return FugitiveHead()
    endf

    func! _stl_clip(win)
        if !empty(&clipboard) && a:win.width > 60
            return substitute(&clipboard, '\vplus$', '+', '')
        end
        return ''
    endf

    func! _stl_regtee(win)
        try
            let reg = luaeval("require('regtee').register")
        catch /.*/
            let reg = ""
        endtry
        if empty(reg)
            return ''
        end
        let lines = len(getreg(reg)) ? len(getreg(reg, 1, 1)) : 0
        let chars = strchars(getreg(reg))
        return printf("@%s %dL %dc", reg, lines, chars)
    endf

    func! _stl_mode(win)
        let map = {'n': 'normal', 'v': 'visual', 'V': 'visual', 'i': 'insert', 'c': 'cmd'}
        return toupper('--'.get(map, mode(), mode()).'--')
    endf

    func! _stl()
        let ret = ''
        let win = getwininfo(g:statusline_winid)[0]
        let sep = win.width < 120 ? ' ' : '  '
        let pad = win.width < 120 ? '' : ' '
        let W = {s -> empty(s) ? '' : '{' . pad . s . pad . '}' }
        try
            let items = []
            call add(items, W(_stl_git_status(win)))
            call add(items, W(_stl_alternate(win)))
            call add(items, _stl_buffer(win, sep))
            call add(items, '%=')
            call add(items, '%=')
            call add(items, W(_stl_regtee(win)))
            call add(items, W(_stl_qf(win)))
            call add(items, W(_stl_venv(win)))
            call add(items, W(_stl_clip(win)))
            call add(items, W(_stl_meta(win)))
            if win.width > 80
                call add(items, W('%1lL, %02cC, %P'))
            end
            call filter(items, {_, v -> !empty(v)})
            return ' ' . join(items, sep) . ' '
        catch /.*/
            return matchstr(v:exception, '\vE\d+:.*')
        endtry
    endf

    set stl=%!_stl()

" TABS
" ----------------------------------------------------------------------------


    func! _tabline()
        let tabline = ''
        for tabnr in range(1, tabpagenr('$'))
            let tab_windows = gettabinfo(tabnr)[0]["windows"]
            let tab_filetype = gettabwinvar(tabnr, tab_windows[0], '&filetype')
            let tabname = gettabvar(tabnr, 'tabname', '')
            let diffview = gettabvar(tabnr, 'diffview_view_initialized', v:false)
            let tabname = diffview ? 'diffview' : tabname
            let tabname = tab_filetype =~? "^neogit" ? 'neogit' : tabname
            let tabname = empty(tabname) ? '' : ':' . tabname
            let tabline .= tabnr == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'
            let tabline .= ' %' . tabnr . 'T'
            let tabline .= printf('[%s%s]', tabnr, tabname)
            let tabline .= ' '
        endfor
        let tabline .= '%#TabLineFill#%T'
        let tabline .= '%=%#TabLine#%999X'
        return tabline
    endf

    command! -nargs=? Tabname call <sid>set_tabname(<q-args>)

    func! s:set_tabname(name)
        let t:tabname = a:name
        set tabline=%!_tabline()
    endf

    nnoremap <c-w>O <cmd>tabonly<cr>

" WINDOWS
" ----------------------------------------------------------------------------

    aug _windows
        au!
        au VimResized * wincmd = | redraw
    aug END

    " view current buffer in a new tab
    nnoremap <c-w>t <cmd>tabe %<cr>
    tnoremap <c-w>t <c-w><cmd>tabe %<cr>

    nnoremap <silent> <c-w>v <c-w>v<cmd>b#<cr>
    nnoremap <silent> <c-w>s <c-w>s<cmd>b#<cr>

    nnoremap <silent> <left> 3<c-w><
    nnoremap <silent> <right> 3<c-w>>
    nnoremap <silent> <up> <c-w>+
    nnoremap <silent> <down> <c-w>-

    nnoremap <silent> <c-w>C <c-w>o
    nnoremap <c-w>c <cmd>call <sid>close_win()<cr>

    func! s:close_win()
        let diffview = gettabvar(tabpagenr(), 'diffview_view_initialized', '')
        if !empty(diffview)
            tabclose
        else
            sil! exec "norm! \<c-w>c"
        end
    endf

" BUFFERS
" ----------------------------------------------------------------------------

    aug _buffers
        au!
        au BufReadPost * call setpos(".", getpos("'\""))
    aug END

    " switch to the alternate buffer
    nnoremap <c-p> <cmd>call <sid>goto_alternate()<cr>

    func! s:goto_alternate()
        if !empty(&bt)
            return s:err("Not a normal buffer")
        end
        if buflisted(@#)
            buffer #
        elseif !empty(@#)
            call s:err("The alternate buffer has been unlisted")
        else
            call s:err("No alternate buffer")
        end
    endf

    command! -bang -nargs=0 Bwipe call <sid>bdelete('bwipe', <q-bang>)
    command! -bang -nargs=0 Bdelete call <sid>bdelete('bdelete', <q-bang>)

    nnoremap <c-w>d <cmd>Bdelete!<cr>
    nnoremap <c-w>D <cmd>Bwipe!<cr>

    " Delete the buffer without closing the window
    func! s:bdelete(cmd, bang)

        let target = bufnr("%")
        if &modified && empty(a:bang)
            return s:err('E89 No write since last change for buffer %d (add ! to override)', target)
        end

        if buflisted(@#) && empty(getbufvar(@#, '&bt'))
            let repl = bufnr(@#)
        else
            let Fn = {i, nr -> buflisted(nr) && empty(getbufvar(nr, '&bt'))}
            let buffers = filter(range(1, bufnr('$')), Fn)
            let repl = buffers[(index(buffers, target)+1) % len(buffers)]
        end

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

        let cmd = a:cmd
        if getbufvar(target, '&buftype') == 'terminal'
            let cmd = 'bwipe!'
        end

        try
            exec cmd target
        catch /E.*/
            return s:err(matchstr(v:exception, '\vE\d+:.*'))
        endtry
    endf

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
    vnoremap a% VGogg
    onoremap a% :<c-u>norm va%<cr>

    " blackhole register shortcut
    nnoremap _ "_
    vnoremap _ "_

    " + register shortcut
    nnoremap + "+
    vnoremap + "+

    " select the last changed text
    nnoremap <expr> gV '`[' . strpart(getregtype(), 0, 1) . '`]'

    " indent last changed text
    nmap g= gV=

    " paste and indent
    nmap <silent> ]P Pg=gqac
    nmap <silent> ]p pg=gqac

    " copy to the end of the line
    nnoremap Y y$

    " indent lines without losing selection
    vnoremap < <gv
    vnoremap > >gv

    " discard empty lines
    nnoremap <silent> <expr> dd (getline(".") =~ '^\s*$' ? '"_dd' : '"'.v:register."dd")

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

    " smooth scrolling with long wrapped lines
    func! _smooth_scroll(direction, count = 1, scrolloff = 1)
        if a:direction > 0
            if line('w$')-a:scrolloff > line('.') || line('$') == line('.')
                exec "norm!" a:count."gj"
            else
                exec "norm!" a:count."\<c-e>".a:count."gj"
            end
        elseif a:direction < 0
            if line('w0')+a:scrolloff < line('.')
                exec "norm!" a:count."gk"
            else
                exec "norm!" a:count."\<c-y>".a:count."gk"
            end
        end
    endf

    " jump after given characters without leaving insert mode
    inoremap <silent> <c-f> <c-r>=_jump_after("\\v[])}>`\"']", 0)<cr>

    func! _jump_after(pattern, sameline = 0)
        let pos = searchpos(a:pattern, 'Wcen')
        if pos == [0, 0] || a:sameline && pos[0] != line('.')
            return ''
        end
        call cursor(pos)
        return "\<right>"
    endf

" COMMAND LINE
" ----------------------------------------------------------------------------

    aug _cmdline_search
        au!
        au CmdlineEnter [/\?] set hlsearch
        au CmdlineLeave [/\?] if v:event.abort | set nohlsearch | end
    aug END

    " use <tab> and <s-tab> instead of <c-g> and <c-t>
    cnoremap <expr> <tab> getcmdtype() =~ '[?/]' ? '<c-g>' : feedkeys('<tab>', 'int')[1]
    cnoremap <expr> <s-tab> getcmdtype() =~ '[?/]' ? '<c-t>' : feedkeys('<s-tab>', 'int')[1]

    cnoremap <c-n> <down>
    cnoremap <c-p> <up>

" SEARCH AND SUBSTITUTE
" ---------------------------------------------------------------------------

    " toggle highlighting of the last search pattern
    nnoremap <c-h> <cmd>set hlsearch!<bar>set hlsearch?<cr>

    " Search withouth moving the cursor
    func! s:search(visual, cmd = '')
        if a:visual && line("'<") != line("'>")
            return
        end
        if a:visual
            let selection = getline('.')[col("'<")-1:col("'>")-1]
            let pattern = '\V' . escape(selection, '/\')
        else
            let pattern = '\<' . expand('<cword>') . '\>'
        end
        if !empty(a:cmd)
            exec a:cmd pattern
        elseif @/ == pattern
            let @/ = ''
            set nohlsearch
        else
            let @/ = pattern
            set hlsearch
        end
    endf

    " Toggle search for current word or selected text without moving the cursor
    nnoremap \ <cmd>call <sid>search(0)<cr>
    vnoremap <silent> \ :<c-u>call <sid>search(1)<cr>
    nnoremap <RightMouse> <LeftMouse><cmd>call <sid>search(0)<cr>
    vnoremap <silent> <RightMouse> :<c-u>call <sid>search(1)<cr>

" REGISTERS
" ----------------------------------------------------------------------------

    " edit registers
    command! -nargs=? Regedit call <sid>regedit(<q-args>)

    func! s:regedit(reg)
        let reg = empty(a:reg) ? '"' : a:reg

        exec "sil keepj keepa botright 1new __regedit__"
        setl ft=regedit bt=nofile bh=wipe nobl noudf nobk noswf nospell
        call setwinvar(winnr(), "&stl", " [Register " . reg . "] ctrl-v to insert control characters")

        let reg_content = getreg(reg, 1, 1)
        call append(1, reg_content)
        sil norm! "_dd

        let min_size = 5
        let max_size = float2nr(&lines * 50 / 100)
        exec "resize" min([max([len(reg_content), min_size]), max_size])

        nno <silent> <buffer> q <c-w>c
        nno <buffer> <cr> <cmd>let b:regedit_save = 1<bar>close<cr>
        nno <buffer> <c-j> <cmd>let b:regedit_save = 1<bar>close<cr>

        let b:regedit_reg = reg
        au BufWipeout <buffer> if get(b:, "regedit_save") | call setreg(b:regedit_reg, join(getline(0, "$"), "\n")) | end
    endf

" MISC
" ----------------------------------------------------------------------------

    aug _misc
        au!

        if has('nvim')
            au TextYankPost * sil! lua vim.highlight.on_yank { higroup="Yank", timeout=150, on_visual=false }
        end

        au VimEnter * clearjumps
        au VimEnter * if isdirectory(expand('%:p')) | exec 'Explorer!' expand('%:p') | end

        au FocusGained,BufEnter,CursorHold * sil! checktime

        au BufWritePost */nvim/init.vim source %
        au BufWritePost */nvim/lua/init.lua luafile %
        au BufWritePost */nvim/colors/*.vim nested exec 'colorscheme' g:colors_name
        au BufWritePost */*Xresources.d/* call <sid>set_bg(&background)
        au BufWritePost */ftplugin/*.vim source % | exec 'au BufEnter ' . expand('#:p') . ' ++once let &ft = &ft'

        " restore cursor position
        au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | end

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

        au BufNewFile,BufRead *.ledger set ft=ledger
        au BufNewFile,BufRead */Xresources.d/* set ft=xdefaults
        au BufNewFile,BufRead *.rasi set ft=css
    aug END

    func! s:err(fmt, ...)
        echohl WarningMsg | echo call('printf', [a:fmt] + a:000)  | echohl None
    endf

    " Clear undo history (:h clear-undo)
    func! s:clear_undo()
        let modified_save = &modified
        let undolevels_save = &undolevels
        let line_save = getline('.')
        set undolevels=-1
        exec "norm! a \<bs>\<esc>"
        call setline('.', line_save)
        let &undolevels = undolevels_save
        let &modified = modified_save
    endf

    " Clear undo history (:h clear-undo)
    command! -nargs=0 ClearUndo call <sid>clear_undo()

    command! -nargs=0 Luarc exec 'edit' $VIMHOME . '/lua/init.lua'
    command! -nargs=0 Vimrc edit $MYVIMRC
    command! -nargs=0 ColorEdit  exec 'e' $VIMHOME.'/colors/' . g:colors_name . '.vim'

    command! -nargs=? -complete=filetype Ftedit call <sid>ft_edit(<q-args>)

    func! s:ft_edit(ft)
        let ft = empty(a:ft) ? &ft : a:ft
        call finder#find($VIMHOME, 'ftplugin.*'.ft.'\.vim$', 1)
    endf

    " Write helpers
    command! -nargs=0 SudoWrite exec 'write !sudo tee % > /dev/null'

    " requires sorting beforehand
    command! Duplicates g/^\(.*\)$\n\1$/p

    nnoremap <2-RightMouse> <nop>
    nnoremap <3-RightMouse> <nop>

    inoremap <c-c> <c-]><esc>
    inoremap <c-u> <c-g>u<c-u>

    inoremap <cr> <c-g>u<cr>

    vnoremap C c

    noremap gj J
    noremap gk K

    iabbrev teh the
    iabbrev wiht with
    iabbrev lenght length
    iabbrev retrun return

    " keep cursor centered in the middle
    command! -nargs=0 Pin let &scrolloff = abs(&scrolloff - 999)<bar>set scrolloff?

    command! -nargs=0 Clip call <sid>toggle_clipboard()
    func! s:toggle_clipboard()
        exec "set clipboard=" . (empty(&clipboard) ? 'unnamedplus' : '')
        redraw!
    endf

    " noremap <c-j> <nop> " marks
" QUICKFIX
" ----------------------------------------------------------------------------

    let g:quickfix_height = 50

    command! -nargs=0 Cclear call setqflist([], 'r')

    nnoremap <leader>q <cmd>copen<cr>
    nnoremap <leader>Q <cmd>cclose<cr>

    nnoremap ]q <cmd>cnext<cr>zz<cr>
    nnoremap ]Q <cmd>clast<cr>zz<cr>
    nnoremap [q <cmd>cprev<cr>zz<cr>
    nnoremap [Q <cmd>cfirst<cr>zz<cr>

    nnoremap <leader>l <cmd>lopen<cr>
    nnoremap <leader>L <cmd>lclose<cr>

    nnoremap ]l <cmd>lnext<cr>zz<cr>
    nnoremap ]L <cmd>llast<cr>zz<cr>
    nnoremap [l <cmd>lprev<cr>zz<cr>
    nnoremap [L <cmd>lfirst<cr>zz<cr>

" Cd
" ----------------------------------------------------------------------------

    let g:root_markers = ['.gitignore', 'go.mod']

    " Find project root
    func! s:find_root(path)
        if empty(a:path) || a:path == '/'
            return ''
        end
        let files = glob(a:path.'/.*', 1, 1) + glob(a:path.'/*', 1, 1)
        let pattern = '\V\^\(' . join(get(g:, 'root_markers', []), '\|') . '\)\$'
        if match(map(files, "fnamemodify(v:val, ':t')"), pattern) >= 0
            return a:path
        end
        return s:find_root(fnamemodify(a:path, ':h'))
    endf

    " Cd into the current project root directory
    func! s:cd_into_root_dir(bang)
        let path = s:find_root(expand('%:p:h'))
        if !empty(path)
            let cd = empty(a:bang) ? 'cd' : 'lcd'
            exec cd fnameescape(path)
            pwd
        end
    endf

    " Cd into the directory of the current buffer
    func! s:cd_into_buf_dir(bang)
        let cd = empty(a:bang) ? 'cd' : 'lcd'
        exec cd fnameescape(expand('%:p:h'))
        pwd
    endf

    command! -bang -nargs=0 Bufcd call <sid>cd_into_buf_dir(<q-bang>)
    command! -bang -nargs=0 Root call <sid>cd_into_root_dir(<q-bang>)

" Search
" ----------------------------------------------------------------------------

    let g:search_mappings_close = ['q', '<esc>', 's', 'S']

    nnoremap s :Search<space>
    nnoremap gs <cmd>Search<cr>

    nnoremap S <cmd>call <sid>search(0, 'Search')<cr>
    vnoremap <silent> S :<c-u>call <sid>search(1, 'Search')<cr>

" Vessel
" ----------------------------------------------------------------------------

    nnoremap gl <plug>(VesselViewLocalJumps)
    nnoremap gL <plug>(VesselViewExternalJumps)

    nnoremap <c-k> <plug>(VesselViewBuffers)
    nnoremap <c-j> <plug>(VesselViewMarks)

    nnoremap m. <plug>(VesselSetLocalMark)
    nnoremap m, <plug>(VesselSetGlobalMark)

    nnoremap <up> <plug>(VesselPinnedPrev)
    nnoremap <down> <plug>(VesselPinnedNext)

" Vifm
" ----------------------------------------------------------------------------

    nnoremap <c-f> <cmd>call <sid>vifm_fzf()<cr>
    nnoremap <c-b> <cmd>exec 'Vifm' expand('%:p:h')<cr>

    func! s:vifm_fzf()
        let path = s:find_root(expand('%:p:h'))
        let path = empty(path) ? getcwd() : path
        exec 'Vifm!' path
    endf

" Spotter
" ----------------------------------------------------------------------------

    let g:spotter_banned_filetypes = {
        \ 'html':1, 'jinja':1, 'htmldjango':1, "json":1,
        \ 'text':1, 'markdown':1, 'notes':1,
    \ }

" Ale
" ----------------------------------------------------------------------------

    let g:ale_enabled = 1
    let g:ale_fix_on_save = 1
    let g:ale_lint_on_text_changed = 'normal'
    let g:ale_virtualtext_cursor = 'never'

    let g:ale_set_loclist = 0
    let g:ale_open_list = 0

    let g:ale_disable_lsp = 0
    let g:ale_use_neovim_diagnostics_api = 1

    let g:ale_linters_explicit = 1
    let g:ale_fixers = {}
    let g:ale_linters = {}

    let g:ale_echo_msg_error_str = 'E'
    let g:ale_echo_msg_warning_str = 'W'
    let g:ale_echo_msg_format = '[%linter%] [%severity%] %s'

    let g:ale_fixers['*'] = ['remove_trailing_lines', 'trim_whitespace']

    let g:ale_linters.python = ['ruff']
    let g:ale_fixers.python = ['ruff', 'ruff_format']
    let g:ale_python_ruff_options = '--select E,F,W,A,PLC,PLE,PLW,I --fixable I'

    let g:ale_linters.go = ['errcheck', 'staticcheck', 'revive']
    let g:ale_fixers.go = ['goimports']

    let g:ale_linters.yaml = ['yamllint']
    let g:ale_fixers.yaml = ['yamlfmt']
    let g:ale_yaml_yamlfmt_options = '-formatter indent=2,retain_line_breaks_single=true,include_document_start=true'

    let g:ale_linters.sh = ['shellcheck']
    " let g:ale_sh_shellcheck_options = '-e SC2181 -e SC2155'

    let g:ale_fixers.lua = ['stylua']

    let g:ale_fixers.javascript = ['prettier']

    let g:ale_fixers.rust = ['rustfmt']

" Git Gutter
" ----------------------------------------------------------------------------

    let g:gitgutter_enabled = 1

" Luasnip
" ----------------------------------------------------------------------------

    imap <silent> <expr> <c-j> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<c-d>'
    inoremap <c-b> <cmd>lua require('luasnip').jump(-1)<Cr>

    snoremap <c-j> <cmd>lua require('luasnip').jump(1)<Cr>
    snoremap <c-b> <cmd>lua require('luasnip').jump(-1)<Cr>

    command! -nargs=? -complete=filetype SnipEdit call <sid>snip_edit(<q-args>)

    func! s:snip_edit(ft)
        let ft = empty(a:ft) ? &ft : a:ft
        if empty(ft)
            return
        end
        let snippet_file = printf('%s/snippets/%s.snippets', $VIMHOME, ft)
        if !filereadable(snippet_file)
            return s:err("No snippets for filetype %s", ft)
        end
        exec "edit" fnameescape(snippet_file)
    endf

" Lazygit
" ----------------------------------------------------------------------------

    nnoremap <c-t> <cmd>call <sid>open_lazygit()<cr>

    func! s:open_lazygit()
        let cwd = shellescape(getcwd())
        if !empty($TMUX)
            let cmd = "tmux display-popup -E -w 90% -h 90% -d " . cwd . " lazygit"
        else
            let cmd = "kitty --name vim-popup -d " . cwd . " -e lazygit"
        end
        call system(cmd)
    endf

" Diffview
" ----------------------------------------------------------------------------

    nnoremap <c-w>f <cmd>DiffviewOpen<cr>

" Disable unused plugins
" ----------------------------------------------------------------------------

    let g:loaded_2html_plugin = 1
    let g:loaded_netrwPlugin = 1

" source local .vimrc
" ----------------------------------------------------------------------------

    if filereadable(expand("~/.vimrc.local"))
        source ~/.vimrc.local
    end

" source init.lua
" ----------------------------------------------------------------------------

    if has('nvim')
        lua require('init')
    end
