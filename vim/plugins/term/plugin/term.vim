" ============================================================================
" File: term.vim
" Description: Improved terminal experience
" Mantainer: github.com/gcmt
" Description: Mostly adapted from http://github.com/sjl/vitality.vim
" License: MIT
" ============================================================================

if exists('g:term_loaded') || &cp
	finish
end
let g:term_loaded = 1

fun! s:tmuxify(str)
	let str = substitute(a:str, "\<Esc>", "\<Esc>\<Esc>", 'g')
	return "\<Esc>Ptmux;" . str . "\<Esc>\\"
endf

fun! s:setup(tmux)

	let enable_focus_reporting = "\<Esc>[?1004h"
	let disable_focus_reporting = "\<Esc>[?1004l"

	" Not to be wrapped in tmux-specific escape sequences
	let save_screen = "\<Esc>[?1049h"
	let restore_screen = "\<Esc>[?1049l"

	let cursor_normal = ""
	let cursor_insert = ""
	let cursor_replace = ""

	if exists('$ITERM_PROFILE')
		" 0 -> block
		" 1 -> bar
		" 2 -> underline
		let cursor_normal = "\<Esc>]50;CursorShape=0\x7"
		let cursor_insert = "\<Esc>]50;CursorShape=1\x7"
		let cursor_replace = "\<Esc>]50;CursorShape=2\x7"
	else
		" 0 -> blinking block
		" 1 -> blinking block
		" 2 -> steady block
		" 3 -> blinking underline
		" 4 -> steady underline
		" 5 -> blinking bar
		" 6 -> steady bar
		let cursor_normal = "\<Esc>[2 q"
		let cursor_insert = "\<Esc>[6 q"
		let cursor_replace = "\<Esc>[4 q"
	end

	if a:tmux
		let enable_focus_reporting = s:tmuxify(enable_focus_reporting) . enable_focus_reporting
		let disable_focus_reporting = disable_focus_reporting
		let cursor_normal = s:tmuxify(cursor_normal)
		let cursor_insert = s:tmuxify(cursor_insert)
		let cursor_replace = s:tmuxify(cursor_replace)
	endif

	" When starting Vim, enable focus reporting and save the screen.
	let &t_ti = cursor_normal . enable_focus_reporting . save_screen . &t_ti
	" When exiting Vim, disable focus reporting and save the screen.
	let &t_te = disable_focus_reporting . restore_screen

	" Use different cursor styles for different modes
	let &t_SI = cursor_insert . &t_SI
	let &t_EI = cursor_normal . &t_EI
	let &t_SR = cursor_replace . &t_SR

	" Map unused keycodes to the sequences iTerm2 is going to send
	" on focus lost/gained.
	exec "set <f24>=\<Esc>[O"
	exec "set <f25>=\<Esc>[I"

	" Handle the focus gained/lost signals in each mode separately.
	nnoremap <silent> <f24> :sil doau FocusLost %<cr>
	nnoremap <silent> <f25> :sil doau FocusGained %<cr>
	onoremap <silent> <f24> <esc>:sil doau FocusLost %<cr>
	onoremap <silent> <f25> <esc>:sil doau FocusGained %<cr>
	vnoremap <silent> <f24> <esc>:sil doau FocusLost %<cr>gv
	vnoremap <silent> <f25> <esc>:sil doau FocusGained %<cr>gv
	inoremap <silent> <f24> <c-\><c-o>:sil doau FocusLost %<cr>
	inoremap <silent> <f25> <c-\><c-o>:sil doau FocusGained %<cr>
	cnoremap <silent> <f24> <c-\>e<sid>doau_cmdline('FocusLost')<cr>
	cnoremap <silent> <f25> <c-\>e<sid>doau_cmdline('FocusGained')<cr>

endf

fun! s:doau_cmdline(event)
	let cmd = getcmdline()
	let pos = getcmdpos()
	exec 'sil doau' a:event '%'
	call setcmdpos(pos)
	return cmd
endf

if exists('$TERM')
	call s:setup(exists('$TMUX'))
end
