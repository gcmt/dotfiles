" ============================================================================
" File: finder.vim
" Description: Find files in the current working directory
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:finder_loaded') || &cp
	finish
end
let g:finder_loaded = 1

" Search for files that match the given pattern.
" Without arguments, the last search results are shown.
command! -bang -nargs=+ -complete=custom,<sid>find_preview Find call <sid>find(<q-bang>, <q-args>)

" Search for files that contain the given pattern.
command! -bang -nargs=+ -complete=custom,<sid>findg_preview Findg call <sid>findg(<q-bang>, <q-args>)

func s:find(bang, args)
	let args = join(split(a:args), '.*')
	let path = empty(a:bang) ? getcwd() : expand('%:p:h')
	call finder#find(path, args)
endf

func s:findg(bang, args)
	let path = empty(a:bang) ? getcwd() : expand('%:p:h')
	call finder#findg(path, a:args)
endf

func s:find_preview(ArgLead, CmdLine, CursorPos)
	let cmd = split(a:CmdLine)
	let bang = matchstr(cmd[0], '\v!$')
	call s:find(bang, join(cmd[1:]))
	redraw | return ''
endf

func s:findg_preview(ArgLead, CmdLine, CursorPos)
	let cmd = split(a:CmdLine)
	let bang = matchstr(cmd[0], '\v!$')
	call s:findg(bang, join(cmd[1:]))
	redraw | return ''
endf

let s:options = {
	\ 'max_winsize': 50,
	\ 'min_winsize': 1,
	\ 'max_results': 100,
\ }

for [s:option, s:default] in items(s:options)
	let g:finder_{s:option} = get(g:, 'finder_'.s:option, s:default)
endfor

func s:setup_colors()
	hi default link FinderDim Comment
endf

call s:setup_colors()

aug _finder
	au BufWritePost .vimrc call <sid>setup_colors()
	au Colorscheme * call <sid>setup_colors()
aug END
