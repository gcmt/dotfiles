" ============================================================================
" File: rofi.vim
" Description: Rofi integration
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if !executable('rofi') || exists('g:rofi_loaded') || &cp
	finish
end
let g:rofi_loaded = 1

" Options
" ----------------------------------------------------------------------------

let s:theme = expand('<sfile>:h') . '/rofi.theme'

let s:default_options = "-monitor '-2' -i -hide-scrollbar -show-match"
let s:default_options .= " -theme " . fnameescape(s:theme)

let g:rofi_options =
	\ get(g:, 'rofi_options', s:default_options)

let g:rofi_width_default =
	\ get(g:, 'rofi_width_default', 50)

let g:rofi_width_rules =
	\ get(g:, 'rofi_width_rules', [['<100', 60], ['<90', 70], ['<80', 80], ['<70', 90]])

" Commands
" ----------------------------------------------------------------------------

command -nargs=? RofiEdit call <sid>rofi_edit(<q-args>)
command -nargs=? RofiSearch call <sid>rofi_search(<q-args>)
command -nargs=0 RofiBuffers call <sid>rofi_buffers()

nnoremap <silent> <leader>r :RofiEdit<cr>

" Code
" ----------------------------------------------------------------------------

func s:win_width() abort
	let width = g:rofi_width_default
	for rule in g:rofi_width_rules
		if rule[0] !~ '\v^\s*((\<|\>)\=?|\=\=)\s*\d+\s*$'
			continue
		end
		if eval('&columns' . rule[0])
			let width = rule[1]
		end
	endfo
	return width
endf

func s:rofi_edit(excmd) abort
	let excmd = empty(a:excmd) ? 'edit' : a:excmd
	let cmd = join([
		\ 'rofi', '-dmenu', '-no-custom', '-p ":edit "' , '-width ' . s:win_width(),
		\ g:rofi_options
	\ ])
	let input = system('rg --files')
	let path = get(systemlist(cmd . ' 2>/dev/null', input), 0, '')
	if !empty(path)
		exec excmd fnameescape(path)
	end
endf

func s:rofi_search(word) abort
	let cmd = join([
		\ 'rofi', '-dmenu', '-no-custom', '-format i', '-p ":search "' , '-width 90',
		\ '-matching normal',
		\ (!empty(a:word) ? "-filter '".a:word."'" : ''),
		\ g:rofi_options
	\ ])
	let lines = map(getline(0, '$'), '[v:key+1, v:val]')
	" remove leading whitespaces
	let lines = map(lines, '[v:val[0], substitute(v:val[1], "\\v^\\s+", "", "")]')
	" keep only lines that have words at least N characters long
	let lines = filter(lines, 'v:val[1] =~ "\\v\\w{3,}"')
	let input = join(map(copy(lines), 'v:val[1]'), "\n")
	let index = get(systemlist(cmd . ' 2>/dev/null', input), 0, '')
	if !empty(index)
		exec lines[index][0]
	end
endf

func s:rofi_buffers() abort
	let buffers = filter(range(1, bufnr('$')), 'buflisted(v:val)')
	let cmd = join([
		\ 'rofi', '-dmenu', '-format i', '-p ":buffer "', '-width ' . s:win_width(),
		\ '-selected-row ' . index(buffers, bufnr('%')),
		\ g:rofi_options
	\ ])
	let input = join(s:format_buffers(buffers), "\n")
	let choice = get(systemlist(cmd . ' 2>/dev/null', input), 0, '')
	if !empty(choice)
		exec 'buffer' buffers[choice]
	end
endf

func s:format_buffers(buffers)
	let buffers = []
	for bufnr in a:buffers
		let line = ''
		let bufname = bufname(bufnr)
		let bufname = empty(bufname) ? bufnr.'|unnamed' : fnamemodify(bufname, ':p')
		let tail = fnamemodify(bufname, ':t')
		let line .= tail
		let line .= getbufvar(bufnr, '&mod') ? ' [+]' : ''
		let path = s:prettify_path(bufname)
		if path != tail
			let line .= ' - ' . path
		end
		call add(buffers, line)
	endfo
	return buffers
endf

func s:prettify_path(path)
	let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
	let path = substitute(path, '\V\^'.$HOME, '~', '')
	return path
endf
