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

	au BufEnter *.js call autotype#javascript#setup()

	au BufEnter *.css,*.scss call autotype#css#setup()

	au BufEnter *.html call autotype#html#setup()

	au BufEnter *.vue call autotype#vue#setup()
	au BufEnter *.vue call autotype#vue#locate_sections()
	au CursorHold *.vue call autotype#vue#locate_sections()

	au FileType python call autotype#python#setup()

	au FileType sh call autotype#sh#setup()
	au FileType zsh call autotype#sh#setup()

	au BufEnter *.ex,*.exs call autotype#elixir#setup()

	au BufEnter *.php call autotype#php#setup()

	au BufEnter *.vim,.vimrc,vimrc call autotype#vim#setup()

aug END
