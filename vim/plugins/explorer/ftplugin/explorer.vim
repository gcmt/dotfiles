
nnoremap <silent> <buffer> q :bdelete<cr>

nnoremap <silent> <buffer> l :call explorer#actions#enter_or_edit()<cr>
nnoremap <silent> <buffer> <right> :call explorer#actions#enter_or_edit()<cr>
nnoremap <silent> <buffer> <enter> :call explorer#actions#enter_or_edit()<cr>

nnoremap <silent> <buffer> h :call explorer#actions#up_dir()<cr>
nnoremap <silent> <buffer> <left> :call explorer#actions#up_dir()<cr>

nnoremap <silent> <buffer> a :call explorer#actions#toggle_hidden_files()<cr>

if get(g:, "loaded_bookmarks", 0)

	func! s:set_mark(mark)
		let file = explorer#actions#get_file_at(line('.'))
		if !empty(file)
			let path = b:explorer.dir . (b:explorer.dir == '/' ? file : '/' . file)
			call bookmarks#set(a:mark, path)
		end
	endf

	nnoremap <silent> <buffer> m :call <sid>set_mark(getchar())<cr>

end
