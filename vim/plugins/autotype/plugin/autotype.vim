" =============================================================================
" File: autotype.vim
" Description: For lazy typers
" Author: github.com/gcmt
" Licence: MIT
" =============================================================================

if exists("g:loaded_autotype") || &cp
	finish
end
let g:loaded_autotype = 1

let g:autotype_disabled = 0

command! -nargs=? -complete=filetype AutotypeEdit call <sid>edit_ft(<q-args>)

func s:edit_ft(filetype)
	let ft = !empty(a:filetype) ? a:filetype : &filetype
	let file = globpath(&rtp, 'autoload/autotype/'. ft . '.vim')
	if !filereadable(file)
		echohl WarningMsg | echo " Can't find filetype" ft | echohl None
		return
	end
	exec 'edit' file
endf

aug _autotype

	au BufWritePost */autoload/autotype/* source %

	" au BufEnter *.js inoremap <silent> <buffer> : <c-]><c-g>u<c-r>=autotype#javascript#colon()<cr>
	au BufEnter *.js inoremap <silent> <buffer> ( <c-]><c-g>u<c-r>=autotype#javascript#outward_parenthesis()<cr>
	au BufEnter *.js inoremap <silent> <buffer> <c-g><c-f> <c-]><c-g>u<c-r>=autotype#javascript#skip_to('\v\}')<cr>
	au BufEnter *.js inoremap <silent> <buffer> { <c-]><c-g>u<c-r>=autotype#javascript#outward_brace()<cr>
	au BufEnter *.js inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=autotype#javascript#space()<cr>
	au BufEnter *.js inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=autotype#javascript#newline()<cr>

	au BufEnter *.css,*.scss inoremap <silent> <buffer> { <c-]><c-g>u<c-r>=autotype#css#outward_brace()<cr>
	" au BufEnter *.css,*.scss inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=autotype#css#space()<cr>
	au BufEnter *.css,*.scss inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=autotype#css#newline()<cr>
	au BufEnter *.css,*.scss inoremap <silent> <buffer> ( <c-]><c-g>u<c-r>=autotype#css#outward_parenthesis()<cr>

	au BufEnter *.html inoremap <silent> <buffer> ! <c-]><c-g>u<c-r>=autotype#html#bang()<cr>
	au BufEnter *.html inoremap <silent> <buffer> <c-j> <c-]><c-g>u<c-r>=autotype#html#newline()<cr>
	au BufEnter *.html inoremap <silent> <buffer> <enter> <c-]><c-g>u<c-r>=autotype#html#newline()<cr>

	au BufEnter *.vue call autotype#vue#locate_sections()
	au CursorHold *.vue call autotype#vue#locate_sections()
	au BufEnter *.vue inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=autotype#vue#space()<cr>
	au BufEnter *.vue inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=autotype#vue#newline()<cr>
	au BufEnter *.vue inoremap <silent> <buffer> ! <c-]><c-g>u<c-r>=autotype#vue#bang()<cr>

	au FileType python inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=autotype#python#newline()<cr>

	au FileType sh inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=autotype#sh#space()<cr>
	au FileType sh inoremap <silent> <buffer> ( <c-]><c-g>u<c-r>=autotype#sh#outward_parenthesis()<cr>

	au BufEnter *.ex,*.exs inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=autotype#elixir#space()<cr>
	au BufEnter *.ex,*.exs inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=autotype#elixir#newline()<cr>

	au BufEnter *.php inoremap <silent> <buffer> . <c-]><c-g>u<c-r>=autotype#php#dot()<cr>
	au BufEnter *.php inoremap <silent> <buffer> : <c-]><c-g>u<c-r>=autotype#php#colon()<cr>
	au BufEnter *.php inoremap <silent> <buffer> ( <c-]><c-g>u<c-r>=autotype#php#outward_parenthesis()<cr>
	au BufEnter *.php inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=autotype#php#newline()<cr>
	au BufEnter *.php inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=autotype#php#space()<cr>

	au BufEnter *.vim,.vimrc,vimrc inoremap <silent> <buffer> <space> <c-]><c-r>=autotype#vim#space()<cr>

aug END
