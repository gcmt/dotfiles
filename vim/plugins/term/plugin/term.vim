" ============================================================================
" File: term.vim
" Description: Improved terminal experience
" Mantainer: github.com/gcmt
" License: MIT
" ============================================================================

if exists('g:term_loaded') || empty($TERM) || &cp
	finish
end
let g:term_loaded = 1

func! s:setup()

	" Use different cursor styles for different modes:
	" - 0 blinking block
	" - 1 blinking block
	" - 2 steady block
	" - 3 blinking underline
	" - 4 steady underline
	" - 5 blinking bar
	" - 6 steady bar
	let &t_EI = s:escape("\<Esc>[2 q")
	let &t_SI = s:escape("\<Esc>[6 q")
	let &t_SR = s:escape("\<Esc>[4 q")

	" Setup focus reporting escape sequences. The first is intepreted by the
	" urxvt focus extension. We use both regardless of the current terminal
	" because in Tmux the $TERM varaible is always the same.
	let focus_on = s:escape("\<Esc>]777;focus;on\007") . "\<Esc>[?1004h"
	let focus_off = s:escape("\<Esc>]777;focus;off\007") . "\<Esc>[?1004l"

	" Enable/disable focus reporting when Vim starts/exits.
	let &t_ti = &t_EI . focus_on . &t_ti
	let &t_te = focus_off . &t_te

	" The terminal sends ^[[I when it gains focus, ^[[O when it loses focus
	exec "set <f24>=\<Esc>[O"
	exec "set <f25>=\<Esc>[I"

	" Handle the focus gained/lost signals in each mode separately
	nnoremap <silent> <f24> :call <sid>doau('FocusLost')<cr>
	nnoremap <silent> <f25> :call <sid>doau('FocusGained')<cr>
	onoremap <silent> <f24> <esc>:call <sid>doau('FocusLost')<cr>
	onoremap <silent> <f25> <esc>:call <sid>doau('FocusGained')<cr>
	vnoremap <silent> <f24> <esc>:call <sid>doau('FocusLost')<cr>gv
	vnoremap <silent> <f25> <esc>:call <sid>doau('FocusGained')<cr>gv
	inoremap <silent> <f24> <c-\><c-o>:call <sid>doau('FocusLost')<cr>
	inoremap <silent> <f25> <c-\><c-o>:call <sid>doau('FocusGained')<cr>
	cnoremap <silent> <f24> <c-\>e<sid>doau_cmdline('FocusLost')<cr>
	cnoremap <silent> <f25> <c-\>e<sid>doau_cmdline('FocusGained')<cr>

endf

" Problem: When splitting the current i3/Tmux layout or when gaining focus
" indirectly by closing a i3/Tmux window/pane, focus events don't get
" triggered. What they do is to 'accumulate' and get triggered all together when
" the Vim window/pane gets focus explicitly or when a key is pressed.
" Solution: When a focus signal is received, delay the 'doautocmd' command by
" N milliseconds so that it can be canceled if another focus signal comes by.
" This will make sure that if a batch of focus signals is received at the same
" time, only the last one gets dispatched.
if has('timers')
	func! s:_doau()
		let id = -1
		func! s:doau(event) closure
			call timer_stop(id)
			let cmd = printf('doau %s %s', a:event, expand('%'))
			let id = timer_start(20, {-> execute(cmd, 'silent')})
		endf
	endf
	call s:_doau()
else
	func! s:doau(event)
		exec 'doau' a:event '%'
	endf
end

func! s:doau_cmdline(event)
	let cmd = getcmdline()
	let pos = getcmdpos()
	call s:doau(a:event)
	call setcmdpos(pos)
	return cmd
endf

func! s:escape(str)
	"if !empty($TMUX)
	"	let str = substitute(a:str, "\<Esc>", "\<Esc>\<Esc>", 'g')
	"	return "\<Esc>Ptmux;" . str . "\<Esc>\\"
	"end
	return a:str
endf

call s:setup()
