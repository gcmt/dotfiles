" =============================================================================
" File: basic.vim
" Description: Black and white colorscheme
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

hi clear
if exists('syntax_on')
	syntax reset
end

set background=light
let g:colors_name = 'basic'

let  s:bg               =  ['ffffff',  255]
let  s:fg               =  ['262626',  0]
let  s:grey             =  ['767676',  0]
let  s:light_grey       =  ['b5b5b5',  0]
let  s:very_light_grey  =  ['ebebeb',  0]
let  s:yellow           =  ['ffff00',  0]
let  s:cyan             =  ['00ffff',  0]
let  s:red              =  ['e64c5a',  0]

fun! s:h(group, fg, bg, attr, sp)
	if !empty(a:fg)
		exec 'hi' a:group 'guifg=#'.a:fg[0] 'ctermfg='.a:fg[1]
	end
	if !empty(a:bg)
		exec 'hi' a:group 'guibg=#'.a:bg[0] 'ctermbg='.a:bg[1]
	end
	if !empty(a:attr)
		 exec 'hi' a:group 'gui='.a:attr 'cterm='.a:attr
	end
	if !empty(a:sp)
		 exec 'hi' a:group 'guisp=#'.a:sp[0]
	end
endf

if has('gui_running') || &t_Co == 88 || &t_Co == 256

	cal s:h('Normal', s:fg, s:bg, '', '')
	cal s:h('Cursor', '', s:fg, '', '')
	cal s:h('NonText', s:light_grey, '', 'none', '')
	cal s:h('SpecialKey', s:very_light_grey, '', 'none', '')
	cal s:h('Conceal', s:very_light_grey, s:bg, '', '')
	cal s:h('Search', s:fg, s:yellow, '', '')
	cal s:h('IncSearch', s:cyan, s:fg, '', '')
	cal s:h('VertSplit', s:fg, s:bg, '', '')
	cal s:h('Visual', s:fg, s:very_light_grey, '', '')
	cal s:h('MatchParen', '', s:very_light_grey, '', '')
	cal s:h('Directory', s:fg, '', '', '')
	cal s:h('Folded', s:fg, s:bg, '', '')
	cal s:h('Hidden', s:bg, s:bg, '', '')
	cal s:h('WildMenu', s:bg, s:grey, 'none', '')

	cal s:h('StatusLineNC', s:fg, s:bg, 'inverse', '')
	cal s:h('StatusLine', s:bg, s:fg, 'none', '')
	cal s:h('StatusLineBold', s:fg, s:bg, 'bold', '')
	cal s:h('StatusLineDim', s:bg, s:fg, 'none', '')
	cal s:h('StatusLineMod', s:bg, s:red, 'none', '')

	cal s:h('LineNr', s:light_grey, '', '', '')
	cal s:h('CursorLineNr', s:fg, '', 'none', '')
	cal s:h('CursorLine', '', s:very_light_grey, 'none', '')
	cal s:h('CursorColumn', '', s:very_light_grey, '', '')
	cal s:h('ColorColumn', '', s:very_light_grey, '', '')
	cal s:h('SignColumn', s:light_grey, s:bg, '', '')
	cal s:h('FoldColumn', s:light_grey, s:bg, '', '')

	cal s:h('WarningMsg', s:red, s:bg, '', '')
	cal s:h('ErrorMsg', s:red, s:bg, '', '')
	cal s:h('ModeMsg', s:fg, '', 'none', '')
	cal s:h('MoreMsg', s:fg, '', 'none', '')
	cal s:h('Question', s:fg, '', 'none', '')

	cal s:h('DiffAdd', s:fg, s:bg, 'none', '')
	cal s:h('DiffDelete', s:fg, s:bg, 'none', '')
	cal s:h('DiffChange', s:fg, s:bg, 'none', '')
	cal s:h('DiffText', s:fg, s:bg, 'none', '')

	cal s:h('PMenu', s:fg, s:very_light_grey, 'none', '')
	cal s:h('PMenuSel', s:fg, s:light_grey, '', '')
	cal s:h('PMenuSBar', s:fg, s:light_grey, 'none', '')
	cal s:h('PMenuThumb', s:fg, s:very_light_grey, 'none', '')

	cal s:h('TabLine', s:fg, s:bg, 'none', '')
	cal s:h('TabLineSel', s:fg, s:bg, 'none', '')
	cal s:h('TabLineFill', s:fg, s:bg, 'none', '')

	cal s:h('SpellBad', '', '', 'underline', s:red)
	cal s:h('SpellCap', '', '', 'underline', s:red)
	cal s:h('SpellLocal', '', '', 'underline', s:fg)
	cal s:h('SpellRare', '', '', 'underline', s:fg)

	cal s:h('Constant', s:fg, '', '', '')
	cal s:h('String', s:fg, '', '', '')
	cal s:h('Character', s:fg, '', '', '')
	cal s:h('Number', s:fg, '', '', '')
	cal s:h('Boolean', s:fg, '', '', '')
	cal s:h('Float', s:fg, '', '', '')
	cal s:h('Identifier', s:fg, '', 'none', '')
	cal s:h('Function', s:fg, '', '', '')
	cal s:h('Statement', s:fg, '', 'none', '')
	cal s:h('Conditional', s:fg, '', '', '')
	cal s:h('Label', s:fg, '', '', '')
	cal s:h('Repeat', s:fg, '', '', '')
	cal s:h('Comment', s:light_grey, '', '', '')
	cal s:h('Operator', s:fg, '', 'none', '')
	cal s:h('Keyword', s:fg, '', '', '')
	cal s:h('Exception', s:fg, '', '', '')
	cal s:h('PreProc', s:fg, '', '', '')
	cal s:h('Include', s:fg, '', '', '')
	cal s:h('Define', s:fg, '', 'none', '')
	cal s:h('Macro', s:fg, '', 'none', '')
	cal s:h('PreCondit', s:fg, '', '', '')
	cal s:h('Type', s:fg, '', 'none', '')
	cal s:h('StorageClass', s:fg, '', '', '')
	cal s:h('Structure', s:fg, '', '', '')
	cal s:h('Typedef', s:fg, '', '', '')
	cal s:h('Special', s:fg, '', '', '')
	cal s:h('Underlined', s:fg, '', 'underline', '')
	cal s:h('Title', s:fg, '', 'none', '')
	cal s:h('Error', '', s:red, '', '')
	cal s:h('Todo', s:red, s:bg, '', '')
	cal s:h('Noise', s:fg, '', '', '')

	cal s:h('qfError', s:fg, '', '', '')
	cal s:h('qfLineNr', s:fg, '', '', '')
	cal s:h('QuickFixLine', s:bg, s:grey, '', '')

	cal s:h('markdownCode', s:grey, '', '', '')
	cal s:h('markdownURL', s:grey, '', '', '')
	for s:n in range(1, 6)
		cal s:h('htmlH' . s:n, s:fg, '', 'bold', '')
	endfor

end
