
setl textwidth=88

" Generate tags
nnoremap <buffer> <F7> :Ctags --languages=python -f .tags/python/0.project<cr>

" Outline python module
nnoremap <silent> <buffer> <leader>o :Search! \v^\s*\zs(class\|def)><cr>
nnoremap <silent> <buffer> <leader>O :Search! \v^\s*\zs(class)><cr>

" Foramt code
nnoremap <silent> <buffer> <F6> :ALEFix<cr>
inoremap <silent> <buffer> <F6> <esc>:ALEFix<cr>

func! s:adjust_indentation(lines)
	let min_indent = -1
	for line in a:lines
		let indent = len(matchstr(line, '\v^\s*'))
		if min_indent == -1 || indent < min_indent
			let min_indent = indent
		end
	endfo
	let patt = '\v^' . repeat(' ', min_indent)
	return map(a:lines, {i, line -> substitute(line, patt, '', '')})
endf

func! s:run_selection() range
	let lines = getline(a:firstline, a:lastline)
	let lines = filter(lines, {i, line -> line !~ '\v^\s*$'})
	let lines = s:adjust_indentation(lines)
	let out = systemlist('python', join(lines, "\n"))
	if v:shell_error
		call util#err(join(out, "\n"))
	else
		echo join(out, "\n")
	end
endf

vnoremap <silent> <F5> :call <sid>run_selection()<cr>
vnoremap <silent> <leader>r :call <sid>run_selection()<cr>

func! s:run()
	if &modified
		write
	end
	call tmux#run_buffer()
endf

if exists('$TMUX')
	let b:tmux = {'prg': 'python', 'args': [], 'eof': 1}
	nnoremap <silent> <buffer> <leader>r :call <sid>run()<cr>
	nnoremap <silent> <buffer> <F5> :call <sid>run()<cr>
	inoremap <silent> <buffer> <F5> <esc>:call <sid>run()<cr>
	nnoremap <silent> <buffer> <leader>z :call tmux#exec('resizep -Z')<cr>
else
	nnoremap <silent> <buffer> <leader>r :python %<cr>
end

