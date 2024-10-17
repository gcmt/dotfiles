
hi clear
if exists('syntax_on')
    syntax reset
end

let g:colors_name = 'main'

let s:none = ['NONE', 'NONE']
if &background == 'light'
    let s:black         = ['#2c3238', 0]
    let s:red           = ['#ad2f3b', 1]
    let s:green         = ['#158045', 2]
    let s:yellow        = ['#d2b96c', 3]
    let s:blue          = ['#3179b2', 4]
    let s:magenta       = ['#9441a6', 5]
    let s:cyan          = ['#158cb0', 6]
    let s:white         = ['#ffffff', 7]
    let s:orange        = ['#c77408', 16]
    let s:fg_dim        = ['#6a737d', 21]
    let s:fg_very_dim   = ['#a1aab7', 22]
    let s:fg_super_dim  = ['#dde5ed', 23]
    let s:bg_accent     = ['#f5f6f7', 24]
    let s:hl            = ['#f7f71b', 25]
    let s:select        = ['#2c3238', 26]
    let s:fg            = [s:black[0], 18]
    let s:bg            = [s:white[0], 19]
else
    let s:black         = ['#1e222b', 0]
    let s:red           = ['#945f65', 1]
    let s:green         = ['#768a78', 2]
    let s:yellow        = ['#a39465', 3]
    let s:blue          = ['#657b99', 4]
    let s:magenta       = ['#917086', 5]
    let s:cyan          = ['#739492', 6]
    let s:white         = ['#9898a0', 7]
    let s:orange        = ['#998068', 16]
    let s:fg_dim        = ['#747982', 21]
    let s:fg_very_dim   = ['#626672', 22]
    let s:fg_super_dim  = ['#323640', 23]
    let s:bg_accent     = ['#252933', 24]
    let s:hl            = ['#a39465', 25]
    let s:select        = ['#323640', 26]
    let s:fg            = [s:white[0], 18]
    let s:bg            = [s:black[0], 19]
end

let g:minimal = get(g:, 'minimal', 0)

" make these groups bold in minimal mode
let s:bold = [
    \ 'Keyword', 'Bold', 'StatusLineBold', 'Cursor',
    \ 'Statement', 'Conditional', 'Repeat', 'Operator', 'Exception', 'StorageClass',
    \ 'htmlTagName', 'htmlSpecialTagName', 'htmlEndTag',
    \ 'pythonInclude',
    \ 'jsFunction',
    \ 'goDeclaration', 'goBuiltins', 'goDeclType', 'goLabel', 'goVar', 'goConst',
\ ]
let s:bold = '\v^(' . join(s:bold, '|') . ')$'

" keep these groups colored in minimal mode
let s:colored = [
    \ 'Hidden', 'Normal.*', 'StatusLine.*', 'Fg.*', 'Bg.*',
    \ 'Cyan.*', 'Green.*', 'Blue.*', 'Magenta.*', 'Red.*', 'Yellow.*', 'Orange.*',
    \ 'Comment', 'String', 'Visual', 'Linenr', 'Todo', 'Number',
    \ 'Cursor', 'NonText', 'SpecialKey', 'Conceal',
    \ 'Search', 'CurSearch', 'IncSearch', 'SearchUnderline',
    \ 'VertSplit', 'WinSeparator', 'Visual', 'MatchParen', 'Directory', 'Folded',
    \ 'Linenr', 'CursorLineNr',
    \ 'PopupSelected', 'CursorLine', 'CursorColumn', 'ColorColumn',
    \ 'WarningMsg', 'ErrorMsg', 'ModeMsg', 'MoreMsg', 'Question',
    \ 'DiffAdd', 'DiffDelete', 'DiffChange', 'DiffText',
    \ 'PMenu.*', 'WildMenu',
    \ 'TabLine', 'TabLineSel', 'TabLineFill',
    \ 'SpellBad', 'SpellCap', 'SpellLocal', 'SpellRare',
    \ 'Yank', 'Spotter', 'Float.*', 'QuickFixLine',
    \ 'GitSigns.*', 'GitGutter.*',
    \ 'markdown.*',
    \ 'htmlString',
    \ 'jsonKeyword',
\ ]
let s:colored = '\v^(' . join(s:colored, '|') . ')$'

func! s:h(group, fg, bg, attr, sp) abort
    if empty(a:fg)
        let fg = s:none
    else
        let fg = !g:minimal || a:group =~ s:colored ? a:fg : s:fg
    end
    if empty(a:bg)
        let bg = s:none
    else
        let bg = !g:minimal || a:group =~ s:colored ? a:bg : s:bg
    end
    if g:minimal && a:group =~ s:bold
        let attr = 'bold'
    else
        let attr = empty(a:attr) ? 'NONE' : a:attr
    end
    let sp = empty(a:sp) ? s:none : a:sp
    exec 'hi' a:group 'guifg='.fg[0] 'ctermfg='.fg[1]
    exec 'hi' a:group 'guibg='.bg[0] 'ctermbg='.bg[1]
    exec 'hi' a:group 'gui='.attr 'cterm='.attr
    exec 'hi' a:group 'guisp='.sp[0]
endf

if has('gui_running') || &t_Co == 88 || &t_Co == 256

    cal s:h('Hidden', s:bg, s:bg, '', '')

    cal s:h('Normal', s:fg, '', 'none', '')
    cal s:h('Blue', s:blue, '', 'none', '')
    cal s:h('Cyan', s:cyan, '', 'none', '')
    cal s:h('Green', s:green, '', 'none', '')
    cal s:h('Red', s:red, '', 'none', '')
    cal s:h('Orange', s:orange, '', 'none', '')
    cal s:h('Magenta', s:magenta, '', 'none', '')
    cal s:h('Yellow', s:yellow, '', 'bold', '')
    cal s:h('Fg', s:fg, '', 'none', '')
    cal s:h('Bg', '', s:bg, 'none', '')
    cal s:h('BgAccent', '', s:bg_accent, 'none', '')
    cal s:h('FgDim', s:fg_dim, '', 'none', '')
    cal s:h('FgVeryDim', s:fg_very_dim, '', 'none', '')
    cal s:h('FgSuperDim', s:fg_super_dim, '', 'none', '')
    cal s:h('Bold', s:fg, '', 'bold', '')

    if &bg == 'dark'
        cal s:h('StatusLine', s:fg_dim, s:bg_accent, 'none', '')
    else
        cal s:h('StatusLine', s:fg_dim, s:bg_accent, 'none', '')
    end

    cal s:h('StatusLineNormal', s:fg, s:bg_accent, 'none', '')
    cal s:h('StatusLineAccent', s:fg_dim, s:bg_accent, 'none', '')
    cal s:h('StatusLineMod', s:fg, s:bg_accent, 'bold', '')
    cal s:h('StatusLineIcon', s:fg_very_dim, s:bg_accent, 'none', '')
    cal s:h('StatusLineNC', s:fg_very_dim, s:bg_accent, 'none', '')
    cal s:h('StatusLineBold', s:fg_dim, s:bg_accent, 'bold', '')
    cal s:h('StatusLineDim', s:fg_very_dim, s:bg_accent, 'none', '')
    cal s:h('StatusLineTermNC', s:fg_very_dim, s:bg_accent, 'none', '')
    cal s:h('StatusLineTerm', s:fg_dim, s:bg_accent, 'none', '')
    cal s:h('StatusLineWarn', s:orange, s:bg_accent, 'none', '')
    cal s:h('StatusLineErr', s:red, s:bg_accent, 'none', '')

    cal s:h('Cursor', '', s:magenta, 'bold', '')
    cal s:h('NonText', s:fg_super_dim, '', 'none', '')
    cal s:h('SpecialKey', s:fg_very_dim, '', 'none', '')
    cal s:h('Conceal', s:fg_very_dim, s:bg, '', '')

    cal s:h('WinSeparator', s:fg_super_dim, s:bg, '', '')
    cal s:h('VertSplit', s:fg_super_dim, s:bg, 'none', '')

    if &bg == 'dark'
        cal s:h('Search', s:bg, s:hl, 'bold', '')
        cal s:h('CurSearch', s:bg, s:red, 'bold', '')
    else
        cal s:h('Search', s:fg, s:hl, 'bold', '')
        cal s:h('CurSearch', s:bg, s:red, 'bold', '')
    end

    cal s:h('SearchUnderline', s:red, '', 'underline', 'none')
    cal s:h('IncSearch', s:bg, s:red, 'bold', '')
    cal s:h('Directory', s:blue, '', '', '')
    cal s:h('Folded', s:fg_super_dim, s:bg, '', '')
    cal s:h('Visual', s:fg, s:select, '', '')

    if &bg == 'dark'
        cal s:h('MatchParen', s:bg, s:blue, 'bold', '')
    else
        cal s:h('MatchParen', s:bg, s:fg_very_dim, 'bold', '')
    end

    if &bg == 'dark'
        cal s:h('WildMenu', s:bg, s:blue, 'bold', '')
    else
        cal s:h('WildMenu', s:bg, s:fg_very_dim, 'bold', '')
    end

    cal s:h('NormalFloat', s:fg, '', '', '')
    cal s:h('FloatBorder', s:fg_dim, '', '', '')

    cal s:h('FloatTitle	', s:fg_dim, '', '', '')
    cal s:h('FloatFooter', s:fg_dim, '', '', '')

    cal s:h('Linenr', s:fg_very_dim, '', '', '')
    cal s:h('CursorLineNr', s:red, '', 'bold', '')
    cal s:h('CursorLine', '', s:bg_accent, 'none', '')
    cal s:h('PopupSelected', '', s:bg_accent, 'bold', '')
    cal s:h('CursorColumn', '', s:bg_accent, '', '')
    cal s:h('ColorColumn', '', s:bg_accent, '', '')
    cal s:h('SignColumn', '', s:bg_accent, '', '')
    cal s:h('FoldColumn', s:bg, s:bg, '', '')

    cal s:h('WarningMsg', s:red, s:bg, '', '')
    cal s:h('ErrorMsg', s:red, s:bg, '', '')
    cal s:h('ModeMsg', s:green, '', 'none', '')
    cal s:h('MoreMsg', s:green, '', 'none', '')
    cal s:h('Question', s:green, '', 'none', '')

    cal s:h('DiffAdd', s:bg, s:green, 'bold', '')
    cal s:h('DiffDelete', s:bg, s:red, 'bold', '')
    cal s:h('DiffChange', s:bg, s:yellow, 'bold', '')
    cal s:h('DiffText', s:bg, s:red, 'bold', '')

    cal s:h('PMenu', s:fg_dim, s:bg_accent, 'none', '')
    cal s:h('PMenuExtra', s:fg_very_dim, s:bg_accent, 'none', '')
    cal s:h('PMenuExtraSel', s:bg_accent, s:fg_very_dim, 'bold', '')
    cal s:h('PMenuKind', s:blue, s:bg_accent, 'none', '')
    cal s:h('PMenuKindSel', s:bg_accent, s:blue, 'bold', '')
    cal s:h('PMenuSel', s:bg_accent, s:fg_dim, 'bold', '')
    cal s:h('PMenuSBar', '', s:bg_accent, 'none', '')
    cal s:h('PMenuThumb', '', s:fg_super_dim, 'none', '')

    cal s:h('TabLine', s:fg_dim, s:bg_accent, 'none', '')
    cal s:h('TabLineSel', s:fg_dim, s:bg, 'bold', '')
    cal s:h('TabLineFill', s:fg_dim, s:bg_accent, 'none', '')

    cal s:h('SpellBad', '', '', 'underline', s:red)
    cal s:h('SpellCap', '', '', 'underline', s:orange)
    cal s:h('SpellLocal', '', '', 'underline', s:fg_dim)
    cal s:h('SpellRare', '', '', 'underline', s:fg_dim)

    cal s:h('Variable', s:fg, '', '', '')
    cal s:h('Delimiter', s:fg, '', '', '')
    cal s:h('Constant', s:fg_dim, '', '', '')
    cal s:h('Character', s:green, '', '', '')
    cal s:h('Number', s:magenta, '', '', '')
    cal s:h('Boolean', s:fg_dim, '', '', '')
    cal s:h('Float', s:fg_dim, '', '', '')
    cal s:h('Identifier', s:fg, '', 'none', '')
    cal s:h('Function', s:fg, '', '', '')
    cal s:h('Statement', s:blue, '', 'none', '')
    cal s:h('Comment', s:fg_very_dim, '', '', '')
    cal s:h('Conditional', s:magenta, '', 'none', '')
    cal s:h('Label', s:magenta, '', '', '')
    cal s:h('Repeat', s:orange, '', 'none', '')
    cal s:h('Operator', s:cyan, '', 'none', '')
    cal s:h('Keyword', s:fg, '', '', '')
    cal s:h('Exception', s:red, '', 'none', '')
    cal s:h('PreProc', s:cyan, '', '', '')
    cal s:h('Include', s:magenta, '', '', '')
    cal s:h('Define', s:blue, '', 'none', '')
    cal s:h('Macro', s:orange, '', 'none', '')
    cal s:h('PreCondit', s:magenta, '', '', '')
    cal s:h('Type', s:cyan, '', 'none', '')
    cal s:h('StorageClass', s:cyan, '', '', '')
    cal s:h('Structure', s:cyan, '', '', '')
    cal s:h('Typedef', s:cyan, '', '', '')
    cal s:h('Special', s:fg_dim, '', '', '')
    cal s:h('Underlined', s:fg, '', 'underline', '')
    cal s:h('Title', s:blue, '', 'bold', '')
    cal s:h('Error', s:bg, s:red, '', '')
    cal s:h('Todo', s:red, s:bg, '', '')
    cal s:h('Noise', s:fg_dim, '', '', '')

    if g:minimal && &bg == 'dark'
        cal s:h('String', s:magenta, '', '', '')
    elseif g:minimal && &bg == 'light'
        cal s:h('String', s:blue, '', '', '')
    else
        cal s:h('String', s:green, '', '', '')
    end

    cal s:h('qfError', s:fg_dim, '', '', '')
    cal s:h('qfLineNr', s:fg_very_dim, '', '', '')
    cal s:h('QuickFixLine', '', s:fg_super_dim, '', '')

    cal s:h('Yank', '', s:bg_accent, '', '')

    if g:minimal && &bg == 'dark'
        cal s:h('Spotter', '', s:bg_accent, '', '')
    elseif g:minimal && &bg == 'light'
        cal s:h('Spotter', '', s:bg_accent, '', '')
    else
        cal s:h('Spotter', '', s:bg_accent, '', '')
    end

    cal s:h('GitGutterAdd', s:green, '', '', '')
    cal s:h('GitGutterChange', s:orange, '', '', '')
    cal s:h('GitGutterDelete', s:red, '', '', '')
    cal s:h('GitGutterChangeDelete', s:red, '', '', '')

    cal s:h('elixirKeyword', s:blue, '', '', '')
    cal s:h('elixirAlias', s:fg, '', '', '')
    cal s:h('elixirAtom', s:magenta, '', '', '')
    cal s:h('elixirModuleDeclaration', s:fg, '', '', '')
    cal s:h('elixirBlockInline', s:blue, '', '', '')
    cal s:h('elixirBlockDefinition', s:blue, '', '', '')
    cal s:h('elixirStringDelimiter', s:green, '', '', '')
    cal s:h('elixirVariable', s:magenta, '', '', '')
    cal s:h('elixirDocString', s:fg_super_dim, '', '', '')
    cal s:h('elixirInclude', s:blue, '', '', '')

    cal s:h('pythonDecorator', s:magenta, '', '', '')
    cal s:h('pythonDottedName', s:magenta, '', '', '')
    cal s:h('pythonInclude', s:blue, '', '', '')

    cal s:h('goDeclaration', s:blue, '', '', '')
    cal s:h('goDeclType', s:blue, '', '', '')
    cal s:h('goBuiltins', s:fg, '', '', '')
    cal s:h('goType', s:fg, '', '', '')
    cal s:h('goLabel', s:fg, '', '', '')
    cal s:h('goVar', s:fg, '', '', '')
    cal s:h('goConst', s:fg, '', '', '')
    hi default link goFormatSpecifier String
    hi default link goEscapeC String
    hi default link @function.method.go Keyword
    hi default link @function.builtin.go Keyword
    hi default link @punctuation.delimiter.go Keyword

    cal s:h('htmlTagName', s:blue, '', '', '')
    cal s:h('htmlSpecialTagName', s:blue, '', '', '')
    cal s:h('htmlArg', s:magenta, '', '', '')
    cal s:h('htmlScriptTag', s:fg_super_dim, '', '', '')
    cal s:h('htmlTag', s:fg_super_dim, '', '', '')
    cal s:h('htmlEndTag', s:fg_super_dim, '', '', '')
    cal s:h('htmlSpecialChar', s:fg_super_dim, '', '', '')
    cal s:h('htmlString', s:magenta, '', '', '')
    hi default link @tag.html Keyword
    hi default link @tag.delimiter.html Keyword

    cal s:h('xmlTagName', s:magenta, '', '', '')
    cal s:h('xmlTag', s:fg_super_dim, '', '', '')
    cal s:h('xmlEndTag', s:magenta, '', '', '')
    cal s:h('xmlAttrib', s:blue, '', '', '')
    cal s:h('xmlString', s:fg_dim, '', '', '')

    cal s:h('jinjaVarBlock', s:fg_super_dim, '', '', '')
    cal s:h('jinjaBlock', s:fg_super_dim, '', '', '')
    cal s:h('jinjaBlockName', s:red, '', '', '')
    cal s:h('jinjaTagBlock', s:fg_super_dim, '', '', '')

    cal s:h('djangoVarBlock', s:fg_dim, '', '', '')
    cal s:h('djangoBlock', s:fg_dim, '', '', '')
    cal s:h('djangoTagBlock', s:fg_dim, '', '', '')
    cal s:h('djangoStatement', s:fg_dim, '', '', '')
    cal s:h('djangoBlockName', s:fg_dim, '', '', '')
    cal s:h('djangoFilter', s:fg_dim, '', '', '')

    cal s:h('cssTagName', s:magenta, '', '', '')
    cal s:h('cssClassName', s:magenta, '', '', '')
    cal s:h('cssClassNameDot', s:magenta, '', '', '')
    cal s:h('cssPseudoClassId', s:fg_dim, '', '', '')
    cal s:h('cssProp', s:blue, '', '', '')
    cal s:h('cssValueNumber', s:fg, '', '', '')
    cal s:h('cssUnitDecorators', s:fg, '', '', '')
    cal s:h('cssNoise', s:fg_dim, '', '', '')
    cal s:h('cssBraces', s:fg_dim, '', '', '')

    cal s:h('sassIdentifier', s:magenta, '', '', '')
    cal s:h('sassClass', s:magenta, '', '', '')

    cal s:h('jsFunction', s:blue, '', '', '')
    cal s:h('jsNull', s:fg_dim, '', '', '')
    cal s:h('jsGlobalObjects', s:fg, '', '', '')
    cal s:h('jsExceptions', s:fg, '', '', '')
    cal s:h('jsAsyncKeyword', s:blue, '', '', '')
    cal s:h('jsAwaitKeyword', s:blue, '', '', '')
    cal s:h('jsExportDefault', s:magenta, '', '', '')

    cal s:h('jsonKeyword', s:magenta, '', '', '')
    cal s:h('jsonQuote', s:fg, '', '', '')
    cal s:h('jsonString', s:fg, '', '', '')
    cal s:h('jsonNull', s:fg_dim, '', '', '')
    cal s:h('jsonBoolean', s:fg, '', '', '')
    cal s:h('jsonBraces', s:fg, '', '', '')
    cal s:h('jsonNumber', s:fg, '', '', '')

    cal s:h('vimFunction', s:fg, '', '', '')
    cal s:h('vimFunc', s:fg, '', '', '')
    cal s:h('vimUserFunc', s:fg, '', '', '')
    hi default link @variable.vim Normal

    cal s:h('yamlString', s:green, '', '', '')
    cal s:h('yamlKey', s:magenta, '', '', '')
    hi default link yamlBlockMappingKey Keyword

    hi default link sqlKeyword Keyword

    hi default link snipKeyword Keyword
    hi default link multiSnipText String

    hi default link @variable.lua Normal
    hi default link @lsp.type.variable.lua Normal
    hi default link @lsp.type.keyword.lua Comment
    hi default link @lsp.type.type.lua Comment
    hi default link @lsp.type.parameter.lua Normal

    cal s:h('markdownCode', s:fg_dim, '', '', '')
    cal s:h('markdownCodeBlock', s:fg_dim, '', '', '')
    cal s:h('markdownURL', s:fg_dim, '', 'underline', '')
    cal s:h('markdownBold', s:fg, '', 'bold', '')
    for s:n in range(1, 6)
        cal s:h('markdownH' . s:n, s:fg, '', 'bold', '')
        cal s:h('markdownH' . s:n . "Delimiter", s:magenta, '', 'bold', '')
    endfor

end
