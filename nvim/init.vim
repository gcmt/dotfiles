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
    call add(g:external, 'airblade/vim-gitgutter')
    call add(g:external, 'neovim/nvim-lspconfig')
    call add(g:external, 'nvim-treesitter/nvim-treesitter')
    call add(g:external, 'hrsh7th/nvim-cmp')
    call add(g:external, 'hrsh7th/cmp-nvim-lsp')
    call add(g:external, 'hrsh7th/cmp-nvim-lsp-signature-help')
    call add(g:external, 'hrsh7th/cmp-buffer')
    call add(g:external, 'hrsh7th/cmp-path')

    for s:ext in g:external
        call add(g:plugins, $VIMVENDOR . '/' . split(s:ext, '/')[-1])
    endfor

    let s:rtp = []
    call extend(s:rtp, g:plugins)
    call extend(s:rtp, globpath(join(g:plugins, ','), 'after', 1, 1))
    exec 'set rtp+=' . join(s:rtp, ',')

    command -nargs=0 PlugInstall call util#plug_install()
    command -nargs=0 PlugUpdate call util#plug_update()

" OPTIONS
" ----------------------------------------------------------------------------

    filetype plugin indent on

    if empty($VIMCACHE)
        set shada=
        set shadafile=NONE
        set noundofile
    else
        set shada=!,'100,/100,:100,s100,f1
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
        let conf = $HOME . '/.config/wezterm/wezterm.lua'
        let bg = trim(system(["grep", "-Po", '(?<=colorscheme = ")([a-z]+)(?=")', conf]))
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
    let &showbreak = ""
    set textwidth=80
    set conceallevel=2

    set number
    set relativenumber
    set numberwidth=1
    set nocursorline

    set scrolloff=0
    set sidescrolloff=0
    set smoothscroll
    set mousescroll=ver:6,hor:1

    set virtualedit=block

    set expandtab
    set tabstop=4
    set shiftwidth=0
    set softtabstop=0

    set wildoptions=pum
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
    let &listchars = 'tab:│  ,leadmultispace:│   ,trail:·,nbsp:+,precedes:◂,extends:🢒'

" STATUSLINE
" ----------------------------------------------------------------------------

    func! _stl_buffer(win, sep)
        let bnum = a:win.bufnr
        let bname = bufname(bnum)
        let bt = getbufvar(bnum, '&buftype')
        let ft = getbufvar(bnum, '&filetype')
        let flags = []
        if !empty(bt)
            call add(flags, '[' . bt . ']')
        end
        if getbufvar(bnum, '&previewwindow')
            call add(flags, '[preview]')
        end
        if getbufvar(bnum, '&readonly')
            call add(flags, '[ro]')
        end
        let name = ''
        if empty(bname)
            let name = '[no name]'
        elseif !empty(bt)
            let name = fnamemodify(bname, ':t')
        else
            if winwidth(a:win.winid) < 80
                let name = fnamemodify(bname, ':t')
            elseif winwidth(a:win.winid) < 120
                let name = join(split(fnamemodify(bname, ':p:~'), '/')[-2:], '/')
            else
                let name = fnamemodify(bname, ':p')
                let name = substitute(name, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
                let name = substitute(name, '\V\^'.$HOME, '~', '')
            end
        end
        if !empty(flags)
            let name = name . " " . join(flags)
        end
        let hl = getbufvar(bnum, '&modified') ? "StatusLineErr" : "StatusLineIcon"
        return _i("󰷈", hl) . name
    endf

    func! STLGotoAltBuffer(minwid, clicks, btn, mod)
        call s:goto_alternate()
    endf

    func! _stl_alternate(win)
        if win_getid() != a:win.winid || a:win.width < 80
            return ''
        end
        let alt = expand('#:t')
        if empty(alt) || !buflisted(@#) || expand('#:p') == fnamemodify(bufname(a:win.bufnr), ':p')
            return ""
        end
        return '%@STLGotoAltBuffer@' . _i("") . alt . '%X'
    endf

    func! STLOpenQuickfix(minwid, clicks, btn, mod)
        copen
    endf

    func! STLOpenLoclist(minwid, clicks, btn, mod)
        lopen
    endf

    func! _stl_qf(win, sep)
        if a:win.width < 80
            return []
        end
        let flags = []
        let qlist = getqflist()
        if !empty(qlist)
            call add(flags, '%@STLOpenQuickfix@' . _i("") . len(qlist).'%X')
        end
        let llist = getloclist(a:win.winid)
        if !empty(llist) && win_getid() == a:win.winid
            call add(flags, '%@STLOpenLoclist@' . _i("") . len(llist).'%*%X')
        end
        return join(flags, a:sep)
    endf

    func! _stl_ft(win)
        let ft = getbufvar(a:win.bufnr, '&filetype')
        if !empty(ft)
            return _i("") . ft
        end
    endf

    func! _stl_meta(win)
        let bnum = a:win.bufnr
        let diff = getbufvar(bnum, '&diff')
        let bt = getbufvar(bnum, '&buftype')
        let ff = getbufvar(bnum, '&fileformat')
        let fenc = getbufvar(bnum, '&fileencoding')
        let enc = getbufvar(bnum, '&encoding')
        let enc = printf('%s:%s', fenc ? fenc : enc, ff)
        let items = []
        call filter(items, 'len(v:val)')
        if !empty(items)
            return _i("") . join(items, ', ')
        end
        return ""
    endf

    func! _stl_venv(win)
        let diff = getbufvar(a:win.bufnr, '&diff')
        let bt = getbufvar(a:win.bufnr, '&buftype')
        let ft = getbufvar(a:win.bufnr, '&filetype')
        if !empty(ft) && empty(bt) && a:win.width > 80
            if !diff && ft == 'python' && !empty($VIRTUAL_ENV)
                let venv = fnamemodify($VIRTUAL_ENV, ':t')
                return _i("") . venv
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
            return printf('%s%s', _i(""), branch)
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
        return printf("%s@%s %dL %dc", _i(""), reg, lines, chars)
    endf

    func! _stl_mode(win)
        let map = {'n': 'normal', 'v': 'visual', 'V': 'visual', 'i': 'insert', 'c': 'cmd'}
        return toupper('--'.get(map, mode(), mode()).'--')
    endf

    func! _i(icon, hl = "StatusLineIcon")
        return "%#" . a:hl . "#" . a:icon . '  %*'
    endf

    func! _stl()
        let ret = ''
        let win = getwininfo(g:statusline_winid)[0]
        let sep = win.width < 120 ? '   ' : '   '
        try
            let items = []
            call add(items, _stl_alternate(win))
            call add(items, _stl_buffer(win, sep))
            call add(items, '%=')
            call add(items, '%=')
            call add(items, _stl_regtee(win))
            call add(items, _stl_qf(win, sep))
            call add(items, _stl_venv(win))
            call add(items, _stl_clip(win))
            call add(items, _stl_git_status(win))
            call add(items, _stl_ft(win))
            if win.width > 80
                call add(items, _i("") . '%1lL %02cC %P')
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

    " set tabline=%!_tabline()

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

    command! -nargs=? Tab $tab split | Tabname <args>
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

    nnoremap <silent> <c-w>C <c-w>o
    nnoremap <c-w>c <cmd>call <sid>win_close()<cr>

    func! s:win_close()
        if !empty(gettabvar(tabpagenr(), 'diffview_view_initialized', ''))
            tabclose | return
        end
        close
    endf

    " resize window using percentages
    nnoremap <c-w>_ <cmd>call util#win_resize(&lines-2, "\<c-w>_")<cr>
    nnoremap <c-w>\| <cmd>call util#win_resize(&columns - len(string(line("$"))), "\<c-w>\|")<cr>

    " fit window to content
    nnoremap <c-w>f <cmd>call util#win_fit()<cr>

" BUFFERS
" ----------------------------------------------------------------------------

    aug _buffers
        au!
        " restore cursor position
        au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | end
    aug END

    " switch to the alternate buffer
    nnoremap <bs> <cmd>call util#goto_alternate()<cr>

    command! -bang -nargs=0 Bwipe call util#bdelete('bwipe', <q-bang>)
    command! -bang -nargs=0 Bdelete call util#bdelete('bdelete', <q-bang>)

    nnoremap <c-w>d <cmd>Bdelete!<cr>
    nnoremap <c-w>D <cmd>Bwipe!<cr>

" EDITING
" ----------------------------------------------------------------------------

    " Clear undo history (:h clear-undo)
    command! -nargs=0 ClearUndo call util#clear_undo()

    " Edit registers
    command! -nargs=? Regedit call util#regedit(<q-args>)

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
    nmap g= gV=
    nmap g> gV>

    " indent last changed text
    nmap g= gV=
    nmap g> gV>
    nmap g< gV<

    " paste and indent
    nmap <silent> ]P Pg=gqac
    nmap <silent> ]p pg=gqac
    xmap <silent> ]P Pg=gqac
    xmap <silent> ]p pg=gqac

    " copy to the end of the line
    nnoremap Y y$

    " indent lines without losing selection
    vnoremap < <gv
    vnoremap > >gv

    " discard empty lines
    nnoremap <silent> <expr> dd (getline(".") =~ '^\s*$' ? '"_dd' : '"'.v:register."dd")

    " start replacement only for selection
    vnoremap s :s/\%V

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

    noremap <c-o> <cmd>call util#zz("\<c-o>")<cr>
    noremap <c-i> <cmd>call util#zz("\<c-i>")<cr>

    noremap n <cmd>call util#zz("n")<cr>
    noremap N <cmd>call util#zz("N")<cr>

    " jump after given characters without leaving insert mode
    inoremap <silent> <c-f> <c-r>=util#jump_after("\\v[])}>`\"']", 0)<cr>

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

    " Toggle search for current word or selected text without moving the cursor
    nnoremap \ <cmd>call util#search(0)<cr>
    vnoremap <silent> \ :<c-u>call util#search(1)<cr>
    nnoremap <RightMouse> <LeftMouse><cmd>call util#search(0)<cr>
    vnoremap <silent> <RightMouse> :<c-u>call util#search(1)<cr>

" MISC
" ----------------------------------------------------------------------------

    aug _misc
        au!

        if has('nvim')
            au TextYankPost * sil! lua vim.highlight.on_yank { higroup="Yank", timeout=150, on_visual=false }
        end

        " au VimEnter * clearjumps
        au VimEnter * if isdirectory(expand('%:p')) | exec 'Vifm' expand('%:p') | end

        au FocusGained,BufEnter,CursorHold * sil! checktime

        " au FocusGained,WinEnter * setl cursorline
        " au FocusLost,WinLeave * setl nocursorline

        au BufWritePost */nvim/init.vim source %
        au BufWritePost */nvim/lua/init.lua luafile %
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

        au BufNewFile,BufRead *.ledger set ft=ledger
        au BufNewFile,BufRead */Xresources.d/* set ft=xdefaults
        au BufNewFile,BufRead *.rasi set ft=css
    aug END

    func! s:err(fmt, ...)
        echohl WarningMsg | echo call('printf', [a:fmt] + a:000)  | echohl None
    endf

    command! -nargs=0 Luarc exec 'edit' $VIMHOME . '/lua/init.lua'
    command! -nargs=0 Vimrc edit $MYVIMRC
    command! -nargs=0 ColorEdit  exec 'e' $VIMHOME.'/colors/' . g:colors_name . '.vim'

    command! -nargs=? -complete=filetype Ftedit call util#ft_edit(<q-args>)

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

    command! -nargs=0 Wrap set wrap!

    " keep cursor centered in the middle
    command! -nargs=0 Mid let &scrolloff = abs(&scrolloff - 999)<bar>set scrolloff?

    command! -nargs=0 Clip call <sid>toggle_clipboard()

    func! s:toggle_clipboard()
        exec "set clipboard=" . (empty(&clipboard) ? 'unnamedplus' : '')
        redraw!
    endf

" QUICKFIX
" ----------------------------------------------------------------------------

    let g:quickfix_height = 50

    command! -nargs=0 Cclear call setqflist([], 'r')

    nnoremap <leader>q <cmd>copen<cr>
    nnoremap <leader>Q <cmd>cclose<cr>

    nnoremap ]q <cmd>cnext<cr>zz
    nnoremap ]Q <cmd>clast<cr>zz
    nnoremap [q <cmd>cprev<cr>zz
    nnoremap [Q <cmd>cfirst<cr>zz

    nnoremap <leader>l <cmd>lopen<cr>
    nnoremap <leader>L <cmd>lclose<cr>

    nnoremap ]l <cmd>lnext<cr>zz
    nnoremap ]L <cmd>llast<cr>zz
    nnoremap [l <cmd>lprev<cr>zz
    nnoremap [L <cmd>lfirst<cr>zz

" Cd
" ----------------------------------------------------------------------------

    let g:root_markers = ['.git', 'go.mod', '.obsidian']

    command! -bang -nargs=0 Bufcd call util#cd_buf_dir(<q-bang>)
    command! -bang -nargs=0 Root call util#cd_root_dir(<q-bang>)

" Search
" ----------------------------------------------------------------------------

    let g:search_mappings_close = ['q', '<esc>', 's', 'S']

    nnoremap s :Search<space>
    nnoremap gs <cmd>Search<cr>

    nnoremap S <cmd>call util#search(0, 'Search')<cr>
    vnoremap <silent> S :<c-u>call util#search(1, 'Search')<cr>

" Vessel
" ----------------------------------------------------------------------------

    nnoremap gl <plug>(VesselViewLocalJumps)
    nnoremap gL <plug>(VesselViewExternalJumps)

    nnoremap gb <plug>(VesselViewBuffersSidebar)
    nnoremap <c-k> <plug>(VesselViewBuffers)
    nnoremap <c-j> <plug>(VesselViewMarks)

    nnoremap m. <plug>(VesselSetLocalMark)
    nnoremap m, <plug>(VesselSetGlobalMark)

    nnoremap <c-p> <plug>(VesselPinnedPrev)
    nnoremap <c-n> <plug>(VesselPinnedNext)

" Vifm
" ----------------------------------------------------------------------------

    nnoremap <c-f> <cmd>call <sid>vifm_fzf()<cr>
    nnoremap <c-b> <cmd>exec 'Vifm' expand('%:p:h')<cr>

    func! s:vifm_fzf()
        exec 'Vifm!' util#find_root(expand('%:p:h'), getcwd())
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

" Tmux
" ----------------------------------------------------------------------------

    nnoremap <c-t> <cmd>call system("tmux select-pane -t +")<cr>

" Luasnip
" ----------------------------------------------------------------------------

    imap <silent> <expr> <c-j> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<c-d>'
    inoremap <c-b> <cmd>lua require('luasnip').jump(-1)<Cr>

    snoremap <c-j> <cmd>lua require('luasnip').jump(1)<Cr>
    snoremap <c-b> <cmd>lua require('luasnip').jump(-1)<Cr>

    command! -nargs=? -complete=filetype Snipedit call util#snip_edit(<q-args>)

" Lazygit
" ----------------------------------------------------------------------------

    nnoremap <leader>g <cmd>call util#open_lazygit()<cr>

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
