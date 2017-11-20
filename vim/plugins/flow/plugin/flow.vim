" =============================================================================
" File: flow.vim
" Description: For lazy typers
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

if exists("g:loaded_flow") || &cp
	finish
end
let g:loaded_flow = 1

let g:flow_disabled = 0

command! -nargs=? -complete=filetype FlowEdit call <sid>edit_ft(<q-args>)

func s:edit_ft(filetype)
	let ft = !empty(a:filetype) ? a:filetype : &filetype
	let file = globpath(&rtp, 'autoload/flow/'. ft . '.vim')
	if !filereadable(file)
		echohl WarningMsg | echo " Can't find filetype" ft | echohl None
		return
	end
	exec 'edit' file
endf

aug _flow

	au BufWritePost */autoload/flow/* source %

	au BufEnter *.js inoremap <silent> <buffer> : <c-]><c-g>u<c-r>=flow#javascript#colon()<cr>
	au BufEnter *.js inoremap <silent> <buffer> ( <c-]><c-g>u<c-r>=flow#javascript#outward_parenthesis()<cr>
	au BufEnter *.js inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=flow#javascript#space()<cr>
	au BufEnter *.js inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=flow#javascript#newline()<cr>

	au BufEnter *.css,*.scss inoremap <silent> <buffer> { <c-]><c-g>u<c-r>=flow#css#outward_brace()<cr>
	au BufEnter *.css,*.scss inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=flow#css#space()<cr>
	au BufEnter *.css,*.scss inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=flow#css#newline()<cr>
	au BufEnter *.css,*.scss inoremap <silent> <buffer> ( <c-]><c-g>u<c-r>=flow#css#outward_parenthesis()<cr>

	au BufEnter *.html inoremap <silent> <buffer> ! <c-]><c-g>u<c-r>=flow#html#bang()<cr>
	au BufEnter *.html inoremap <silent> <buffer> <c-j> <c-]><c-g>u<c-r>=flow#html#newline()<cr>
	au BufEnter *.html inoremap <silent> <buffer> <enter> <c-]><c-g>u<c-r>=flow#html#newline()<cr>

	au BufEnter *.vue call flow#vue#locate_sections()
	au CursorHold *.vue call flow#vue#locate_sections()
	au BufEnter *.vue inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=flow#vue#space()<cr>
	au BufEnter *.vue inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=flow#vue#newline()<cr>
	au BufEnter *.vue inoremap <silent> <buffer> ! <c-]><c-g>u<c-r>=flow#vue#bang()<cr>

	au BufEnter *.py inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=flow#python#newline()<cr>

	au BufEnter *.ex,*.exs inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=flow#elixir#space()<cr>
	au BufEnter *.ex,*.exs inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=flow#elixir#newline()<cr>

	au BufEnter *.php inoremap <silent> <buffer> . <c-]><c-g>u<c-r>=flow#php#dot()<cr>
	au BufEnter *.php inoremap <silent> <buffer> : <c-]><c-g>u<c-r>=flow#php#colon()<cr>
	au BufEnter *.php inoremap <silent> <buffer> ( <c-]><c-g>u<c-r>=flow#php#outward_parenthesis()<cr>
	au BufEnter *.php inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=flow#php#newline()<cr>
	au BufEnter *.php inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=flow#php#space()<cr>

	au BufEnter *.vim,.vimrc inoremap <silent> <buffer> <space> <c-]><c-r>=flow#vim#space()<cr>

aug END
