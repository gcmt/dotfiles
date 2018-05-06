
hi clear
if exists('syntax_on')
	syntax reset
end

let g:colors_name = 'main'

if &background == 'light'
	let s:bg           =  ['#ffffff', 19]
	let s:bg_accent    =  ['#e9e9e9', 21]
	let s:fg           =  ['#575a60', 18]
	let s:fg_dim       =  ['#797d84', 22]
	let s:fg_very_dim  =  ['#979aa0', 23]
	let s:fg_super_dim =  ['#c7c7c7', 24]
	let s:red          =  ['#ce616f', 1]
	let s:green        =  ['#629167', 2]
	let s:yellow       =  ['#e2c97c', 3]
	let s:blue         =  ['#5e7da8', 4]
	let s:magenta      =  ['#b274a3', 5]
	let s:cyan         =  ['#60a39d', 6]
	let s:orange       =  ['#d88d61', 16]
else
	let s:bg           =  ['#1e222b', 19]
	let s:bg_accent    =  ['#252933', 21]
	let s:fg           =  ['#8e9299', 18]
	let s:fg_dim       =  ['#636770', 22]
	let s:fg_very_dim  =  ['#444751', 23]
	let s:fg_super_dim =  ['#353944', 24]
	let s:red          =  ['#945F65', 1]
	let s:green        =  ['#768A78', 2]
	let s:yellow       =  ['#A39465', 3]
	let s:blue         =  ['#657B99', 4]
	let s:magenta      =  ['#917086', 5]
	let s:cyan         =  ['#739492', 6]
	let s:orange       =  ['#998068', 16]
end

func! s:h(group, fg, bg, attr, sp)
	if !empty(a:fg)
		exec 'hi' a:group 'guifg='.a:fg[0] 'ctermfg='.a:fg[1]
	end
	if !empty(a:bg)
		exec 'hi' a:group 'guibg='.a:bg[0] 'ctermbg='.a:bg[1]
	end
	if !empty(a:attr)
		 exec 'hi' a:group 'gui='.a:attr 'cterm='.a:attr
	end
	if !empty(a:sp)
		 exec 'hi' a:group 'guisp='.a:sp[0]
	end
endf

if has('gui_running') || &t_Co == 88 || &t_Co == 256

	cal s:h('Hidden', s:bg, s:bg, '', '')

	cal s:h('Normal', s:fg, s:bg, '', '')
	cal s:h('NormalBold', s:fg, s:bg, 'bold', '')
	cal s:h('NormalReverse', s:bg, s:fg, '', '')
	cal s:h('NormalBoldReverse', s:bg, s:fg, 'bold', '')

	cal s:h('Blue', s:blue, '', 'none', '')
	cal s:h('BlueReverse', s:blue, '', 'reverse', '')
	cal s:h('BlueBold', s:blue, '', 'bold', '')
	cal s:h('BlueBoldReverse', s:blue, '', 'reverse,bold', '')

	cal s:h('Cyan', s:cyan, '', 'none', '')
	cal s:h('CyanReverse', s:cyan, '', 'reverse', '')
	cal s:h('CyanBold', s:cyan, '', 'bold', '')
	cal s:h('CyanBoldReverse', s:cyan, '', 'reverse,bold', '')

	cal s:h('Green', s:green, '', 'none', '')
	cal s:h('GreenReverse', s:green, '', 'reverse', '')
	cal s:h('GreenBold', s:green, '', 'bold', '')
	cal s:h('GreenBoldReverse', s:green, '', 'reverse,bold', '')

	cal s:h('Red', s:red, '', 'none', '')
	cal s:h('RedReverse', s:red, '', 'reverse', '')
	cal s:h('RedBold', s:red, '', 'bold', '')
	cal s:h('RedBoldReverse', s:red, '', 'reverse,bold', '')

	cal s:h('Orange', s:orange, '', 'none', '')
	cal s:h('OrangeReverse', s:orange, '', 'reverse', '')
	cal s:h('OrangeBold', s:orange, '', 'bold', '')
	cal s:h('OrangeBoldReverse', s:orange, '', 'reverse,bold', '')

	cal s:h('Magenta', s:magenta, '', 'none', '')
	cal s:h('MagentaReverse', s:magenta, '', 'reverse', '')
	cal s:h('MagentaBold', s:magenta, '', 'bold', '')
	cal s:h('MagentaBoldReverse', s:magenta, '', 'reverse,bold', '')

	cal s:h('Yellow', s:yellow, '', 'none', '')
	cal s:h('YellowReverse', s:yellow, '', 'reverse', '')
	cal s:h('YellowBold', s:yellow, '', 'bold', '')
	cal s:h('YellowBoldReverse', s:yellow, '', 'reverse,bold', '')

	cal s:h('Fg', s:fg, '', 'none', '')
	cal s:h('FgReverse', s:fg, '', 'reverse', '')
	cal s:h('FgBold', s:fg, '', 'bold', '')
	cal s:h('FgBoldReverse', s:fg, '', 'reverse', '')

	cal s:h('FgDim', s:fg_dim, '', 'none', '')
	cal s:h('FgDimReverse', s:fg_dim, '', 'reverse', '')
	cal s:h('FgDimBold', s:fg_dim, '', 'bold', '')
	cal s:h('FgDimBoldReverse', s:fg_dim, '', 'reverse', '')

	cal s:h('FgVeryDim', s:fg_super_dim, '', 'none', '')
	cal s:h('FgVeryDimReverse', s:fg_super_dim, '', 'reverse', '')
	cal s:h('FgVeryDimBold', s:fg_super_dim, '', 'bold', '')
	cal s:h('FgVeryDimBoldReverse', s:fg_super_dim, '', 'reverse', '')

	cal s:h('StatusLineNC', s:fg_very_dim, s:bg_accent, 'none', '')
	cal s:h('StatusLine', s:fg_dim, s:bg_accent, 'none', '')
	cal s:h('rStatusLineDim', s:fg_super_dim, s:bg_accent, 'none', '')
	cal s:h('StatusLineBold', s:fg_dim, s:bg_accent, 'bold', '')
	cal s:h('StatusLineMod', s:red, s:bg_accent, 'none', '')

	cal s:h('StatusLineBlue', s:blue, s:bg_accent, 'none', '')
	cal s:h('StatusLineBlueBold', s:blue, s:bg_accent, 'bold', '')
	cal s:h('StatusLineCyan', s:cyan, s:bg_accent, 'none', '')
	cal s:h('StatusLineCyanBold', s:cyan, s:bg_accent, 'bold', '')
	cal s:h('StatusLineGreen', s:green, s:bg_accent, 'none', '')
	cal s:h('StatusLineGreenBold', s:green, s:bg_accent, 'bold', '')
	cal s:h('StatusLineRed', s:red, s:bg_accent, 'none', '')
	cal s:h('StatusLineRedBold', s:red, s:bg_accent, 'bold', '')
	cal s:h('StatusLineMagenta', s:magenta, s:bg_accent, 'none', '')
	cal s:h('StatusLineMagentaBold', s:magenta, s:bg_accent, 'bold', '')
	cal s:h('StatusLineOrange', s:orange, s:bg_accent, 'none', '')
	cal s:h('StatusLineOrangeBold', s:orange, s:bg_accent, 'bold', '')
	cal s:h('StatusLineYellow', s:yellow, s:bg_accent, 'none', '')
	cal s:h('StatusLineYellowBold', s:yellow, s:bg_accent, 'bold', '')
	cal s:h('StatusLineFgDim', s:fg_dim, s:bg_accent, 'none', '')
	cal s:h('StatusLineFgDimBold', s:fg_dim, s:bg_accent, 'bold', '')
	cal s:h('StatusLineFgVeryDim', s:fg_very_dim, s:bg_accent, 'none', '')
	cal s:h('StatusLineFgVeryDimBold', s:fg_very_dim, s:bg_accent, 'bold', '')

	cal s:h('Cursor', '', s:magenta, '', '')
	cal s:h('NonText', s:bg_accent, '', 'none', '')
	cal s:h('SpecialKey', s:bg_accent, '', 'none', '')
	cal s:h('Conceal', s:fg_dim, s:bg, '', '')
	cal s:h('Search', s:bg, s:yellow, '', '')
	cal s:h('IncSearch', s:bg, s:red, 'none', '')
	cal s:h('VertSplit', s:fg_super_dim, s:bg, 'none', '')
	cal s:h('Visual', s:fg, s:fg_super_dim, '', '')
	cal s:h('MatchParen', s:bg, s:yellow, '', '')
	cal s:h('Directory', s:blue, '', '', '')
	cal s:h('Folded', s:fg_super_dim, s:bg, '', '')
	cal s:h('WildMenu', s:bg, s:blue, '', '')

	cal s:h('Linenr', s:fg_super_dim, '', '', '')
	cal s:h('CursorLineNr', s:red, '', 'none', '')
	cal s:h('CursorLine', '', s:bg_accent, 'none', '')
	cal s:h('CursorColumn', '', s:bg_accent, '', '')
	cal s:h('ColorColumn', '', s:bg_accent, '', '')
	cal s:h('SignColumn', '', s:bg, '', '')
	cal s:h('FoldColumn', s:bg, s:bg, '', '')

	cal s:h('WarningMsg', s:red, s:bg, '', '')
	cal s:h('ErrorMsg', s:red, s:bg, '', '')
	cal s:h('ModeMsg', s:green, '', 'none', '')
	cal s:h('MoreMsg', s:green, '', 'none', '')
	cal s:h('Question', s:green, '', 'none', '')

	cal s:h('DiffAdd', s:bg, s:green, 'none', '')
	cal s:h('DiffDelete', s:bg, s:red, 'none', '')
	cal s:h('DiffChange', s:bg, s:yellow, 'none', '')
	cal s:h('DiffText', s:bg, s:red, 'none', '')

	cal s:h('PMenu', s:fg_dim, s:bg_accent, 'none', '')
	cal s:h('PMenuSel', s:bg_accent, s:fg_dim, '', '')
	cal s:h('PMenuSBar', s:bg_accent, s:bg_accent, 'none', '')
	cal s:h('PMenuThumb', s:fg_dim, s:bg_accent, 'none', '')

	cal s:h('TabLine', s:fg_super_dim, s:bg_accent, 'none', '')
	cal s:h('TabLineSel', s:fg_dim, s:bg, 'none', '')
	cal s:h('TabLineFill', s:fg_dim, s:bg_accent, 'none', '')

	cal s:h('SpellBad', '', '', 'underline', s:red)
	cal s:h('SpellCap', '', '', 'underline', s:orange)
	cal s:h('SpellLocal', '', '', 'underline', s:fg_dim)
	cal s:h('SpellRare', '', '', 'underline', s:fg_dim)

	cal s:h('Constant', s:fg_dim, '', '', '')
	cal s:h('String', s:green, '', '', '')
	cal s:h('Character', s:green, '', '', '')
	cal s:h('Number', s:fg_dim, '', '', '')
	cal s:h('Boolean', s:fg_dim, '', '', '')
	cal s:h('Float', s:fg_dim, '', '', '')
	cal s:h('Identifier', s:fg, '', 'none', '')
	cal s:h('Function', s:fg, '', '', '')
	cal s:h('Statement', s:blue, '', 'none', '')
	cal s:h('Conditional', s:magenta, '', '', '')
	cal s:h('Label', s:magenta, '', '', '')
	cal s:h('Repeat', s:orange, '', '', '')
	cal s:h('Comment', s:fg_very_dim, '', '', '')
	cal s:h('Operator', s:cyan, '', 'none', '')
	cal s:h('Keyword', s:fg, '', '', '')
	cal s:h('Exception', s:red, '', '', '')
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
	cal s:h('Underlined', s:fg_super_dim, '', 'underline', '')
	cal s:h('Title', s:blue, '', 'none', '')
	cal s:h('Error', s:bg, s:red, '', '')
	cal s:h('Todo', s:red, s:bg, '', '')
	cal s:h('Noise', s:fg_dim, '', '', '')

	cal s:h('qfError', s:fg_dim, '', '', '')
	cal s:h('qfLineNr', s:fg_dim, '', '', '')
	cal s:h('QuickFixLine', s:bg, s:fg_dim, '', '')

	cal s:h('Yank', '', s:bg_accent, '', '')
	cal s:h('Spotter', '', s:bg_accent, '', '')

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

	cal s:h('htmlTagName', s:blue, '', '', '')
	cal s:h('htmlSpecialTagName', s:blue, '', '', '')
	cal s:h('htmlArg', s:magenta, '', '', '')
	cal s:h('htmlScriptTag', s:fg_super_dim, '', '', '')
	cal s:h('htmlTag', s:fg_super_dim, '', '', '')
	cal s:h('htmlEndTag', s:fg_super_dim, '', '', '')
	cal s:h('htmlSpecialChar', s:fg_super_dim, '', '', '')
	cal s:h('htmlString', s:green, '', '', '')

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
	cal s:h('jsonQuote', s:fg_dim, '', '', '')
	cal s:h('jsonString', s:fg, '', '', '')
	cal s:h('jsonNull', s:fg_dim, '', '', '')
	cal s:h('jsonBoolean', s:fg_dim, '', '', '')
	cal s:h('jsonBraces', s:fg, '', '', '')

	cal s:h('yamlString', s:green, '', '', '')
	cal s:h('yamlKey', s:magenta, '', '', '')

	cal s:h('markdownCode', s:fg_dim, '', '', '')
	cal s:h('markdownURL', s:fg_dim, '', '', '')
	for s:n in range(1, 6)
		cal s:h('htmlH' . s:n, s:magenta, '', 'none', '')
	endfor

end
