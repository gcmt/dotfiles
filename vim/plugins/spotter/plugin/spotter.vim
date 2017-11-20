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

let g:spotter_banned_filetypes =
	\ extend({ 'netrw':1 }, get(g:, "spotter_banned_filetypes", {}))

" to ban words by filetype use g:spotter_banned_words_{filetype}
let g:spotter_banned_words =
	\ get(g:, "spotter_banned_words", {})

" to ban syntax by filetype use g:spotter_banned_syntax_{filetype}
let g:spotter_banned_syntax =
	\ extend({
		\ 'Statement':1, 'Repeat':1, 'Exception':1,
		\ 'Conditional':1, 'Number':1, 'Float':1, 'Boolean':1, 'Label':1,
		\ 'Operator':1, 'PreProc':1, 'Include':1, 'Define':1,
	\ }, get(g:, 'spotter_banned_syntax', {}))

" Main
" -----------------------------------------------------------------------------

let s:id = -1

func s:highlight_word()

	if !g:spotter_active
		return
	end

	call s:clear_highlighting()

	if !empty(&bt) || get(g:spotter_banned_filetypes, &ft)
		return
	end

	 " detect syntax under cursor
	let syntax = synIDattr(synIDtrans(synID(line("."), col("."), 0)), 'name')
	let blacklist = extend(get(g:, "spotter_banned_syntax_".&ft, {}), g:spotter_banned_syntax)
	if get(blacklist, syntax)
		return
	end

	let word = expand("<cword>")
	if word !~ '\v^[-a-zA-Z_][-a-zA-Z0-9_]{'.g:spotter_treshold.',}$'
		return
	end

	let blacklist = extend(get(g:, "spotter_banned_words_".&ft, {}), g:spotter_banned_words)
	if get(blacklist, word)
		return
	end

	" check if the word is really under the cursor (expanding <cword> may return the next word)
	if strpart(getline('.'), col('.') - len(word), len(word)*2 - 1) !~ word
		return
	end

	" search for the word in the visible part of the buffer
	let pattern = printf('\V\%%>%dl\%%<%dl\<%s\>', line('w0')-1, line('w$')+1, word)
	let s:id = matchadd("Spotter", pattern, -1)

endf

func s:clear_highlighting()
	if s:id > 0
		sil! call matchdelete(s:id)
		let s:id = -1
	end
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
	au CursorMoved,InsertEnter,WinLeave * call <sid>clear_highlighting()
	au CursorHold * call <sid>highlight_word()
	au BufWritePost .vimrc call <sid>setup_colors()
	au Colorscheme * call <sid>setup_colors()
aug END
