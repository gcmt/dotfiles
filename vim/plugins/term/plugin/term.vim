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

	" When starting vim, enable focus reporting
	let &t_ti = &t_EI . "\<Esc>[?1004h" . &t_ti
	" When exiting vim, disable focus reporting
	let &t_te = "\<Esc>[?1004l" . &t_te

	" The terminal sends ^[[I when focusing, ^[[O when defocusing
	exec "set <f24>=\<Esc>[O"
	exec "set <f25>=\<Esc>[I"

	" Handle the focus gained/lost signals in each mode separately
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

func! s:escape(str)
	if !empty($TMUX)
		let str = substitute(a:str, "\<Esc>", "\<Esc>\<Esc>", 'g')
		return "\<Esc>Ptmux;" . str . "\<Esc>\\"
	end
	return a:str
endf

func! s:doau_cmdline(event)
	let cmd = getcmdline()
	let pos = getcmdpos()
	exec 'sil doau' a:event '%'
	call setcmdpos(pos)
	return cmd
endf

call s:setup()
