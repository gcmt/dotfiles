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

command! -nargs=? -complete=filetype FlowEdit call <sid>edit(<q-args>)

func s:edit(file)
	let file = !empty(a:file) ? a:file . '.vim' : 'common.vim'
	let path = globpath(&rtp, 'autoload/flow/'. file)
	if !filereadable(path)
		echohl WarningMsg | echo " Can't find file" ft | echohl None
		return
	end
	exec 'edit' fnameescape(path)
endf

aug _flow

	au BufWritePost */autoload/flow/* source %

	au BufEnter * call flow#common#setup()

	au BufEnter *.js,*.jsx call flow#javascript#setup()

	au BufEnter *.js,*.jsx,*.ts,*.tsx,*.html call flow#tag#setup()

	au BufEnter *.css,*.scss call flow#css#setup()

	au BufEnter *.html call flow#html#setup()

	au BufEnter *.vue call flow#vue#setup()
	au BufEnter *.vue call flow#vue#locate_sections()
	au CursorHold *.vue call flow#vue#locate_sections()

	au FileType python call flow#python#setup()

	au FileType sh call flow#sh#setup()
	au FileType zsh call flow#sh#setup()

	au BufEnter *.ex,*.exs call flow#elixir#setup()

	au BufEnter *.php call flow#php#setup()

	au BufEnter *.vim,.vimrc,vimrc call flow#vim#setup()

aug END
