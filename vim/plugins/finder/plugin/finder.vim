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
command! -nargs=+ -complete=custom,<sid>find_preview Find call <sid>find(<q-args>)

" Search for files that contain the given pattern.
command! -nargs=+ -complete=custom,<sid>findg_preview Findg call <sid>findg(<q-args>)

func s:find(args)
	let args = join(split(a:args), '.*')
	call finder#find(getcwd(), args)
endf

func s:findg(args)
	call finder#findg(getcwd(), a:args)
endf

func s:find_preview(ArgLead, CmdLine, CursorPos)
	let args = join(split(a:CmdLine)[1:])
	call s:find(args)
	redraw | return ''
endf

func s:findg_preview(ArgLead, CmdLine, CursorPos)
	let args = join(split(a:CmdLine)[1:])
	call s:findg(args)
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
