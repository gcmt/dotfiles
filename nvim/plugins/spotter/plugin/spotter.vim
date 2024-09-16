" =============================================================================
" File: spotter.vim
" Description: Highlight the word under cursor
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

if exists("g:loaded_spotter") || &cp
    finish
end
let g:loaded_spotter = 1

" Settings
" -----------------------------------------------------------------------------

let g:spotter_active =
    \ get(g:, "spotter_active", 1)

let g:spotter_treshold =
    \ get(g:, "spotter_treshold", 2)

" to ban words by filetype use g:spotter_banned_words_{filetype}
let g:spotter_banned_words =
    \ get(g:, "spotter_banned_words", {})

let g:spotter_banned_filetypes =
    \ extend({ 'netrw':1 }, get(g:, "spotter_banned_filetypes", {}))

" to ban syntax by filetype use g:spotter_banned_syntax_{filetype}
let g:spotter_banned_syntax =
    \ extend({
        \ 'Statement':1, 'Repeat':1, 'Exception':1, 'Conditional':1, 'Keyword': 1,
        \ 'Number':1, 'Float':1, 'Boolean':1, 'String': 1, 'Label':1,
        \ 'Operator':1, 'PreProc':1, 'Include':1, 'Define':1, 'Comment': 1,
    \ }, get(g:, 'spotter_banned_syntax', {}))

" Main
" -----------------------------------------------------------------------------

if has('nvim')
    " s:synat({line:number}, {col:number}, {bufnr:number}) -> dict
    " Return the syntax groups at the given position.
    func! s:synat(line, col, bufnr = 0)
        let ret = {}
        let table = luaeval(printf("vim.inspect_pos(%s, %s, %s)", a:bufnr, a:line-1, a:col-1))
        let syntaxes = empty(table['syntax']) ? table['treesitter'] : table['syntax']
        for syn in syntaxes
            let group = empty(syn['hl_group_link']) ? syn['hl_group'] : syn['hl_group_link']
            let ret[tolower(group)] = 1
        endfor
        return ret
    endf
else
    " s:synat({line:number}, {col:number}, {bufnr:number}) -> dict
    func! s:synat(line, col, bufnr = 0)
        return {synIDattr(synIDtrans(synID(a:line, a:col, 0)), 'name'): 1}
    endf
end

func s:highlight_word()

    if !g:spotter_active
        return
    end

    if &diff || !empty(&bt) || get(g:spotter_banned_filetypes, &ft)
        return
    end

    let cursor_syn = s:synat(line("."), col("."), bufnr('%'))
    for banned_syn in keys(extend(get(g:, "spotter_banned_syntax_".&ft, {}), g:spotter_banned_syntax))
        if has_key(cursor_syn, tolower(banned_syn))
            return
        end
    endfor

    let word = expand("<cword>")
    if word !~ '\v^[-a-zA-Z_][-a-zA-Z0-9_]{'.g:spotter_treshold.',}$'
        return
    end

    let blacklist = extend(get(g:, "spotter_banned_words_".&ft, {}), g:spotter_banned_words)
    if get(blacklist, tolower(word))
        return
    end

    " check if the word is really under the cursor (expanding <cword> may return the next word)
    if strpart(getline('.'), col('.') - len(word), len(word)*2 - 1) !~ word
        return
    end

    " search for the word in the visible part of the buffer
    let pattern = printf('\V\%%>%dl\%%<%dl\<%s\>', line('w0')-1, line('w$')+1, word)
    let id = matchadd("Spotter", pattern, -1)

    " delete the match
    exec 'au CursorMoved,InsertEnter,WinLeave * ++once sil! call matchdelete(' . id . ')'
endf

" Colors
" -----------------------------------------------------------------------------

func s:setup_colors()
    hi default link Spotter MatchParen
endf

call s:setup_colors()

" Autocommands
" -----------------------------------------------------------------------------

aug _spotter
    au CursorHold * call <sid>highlight_word()
    au BufWritePost .vimrc call <sid>setup_colors()
    au Colorscheme * call <sid>setup_colors()
aug END
