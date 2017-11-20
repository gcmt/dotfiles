
let g:tagbar_type_go = {
	\ 'ctagstype' : 'go',
	\ 'kinds' : [
		\ 'p:package:1','i:imports:1','c:constants','v:variables','t:types', 'n:interfaces',
		\ 'w:fields','e:embedded','m:methods','r:constructor', 'f:functions'
	\ ],
	\ 'sro' : '.',
	\ 'kind2scope' : {'t' : 'ctype', 'n' : 'ntype'},
	\ 'scope2kind' : {'ctype' : 't', 'ntype' : 'n'},
	\ 'ctagsbin' : $HOME.'/.gotools/bin/gotags',
	\ 'ctagsargs' : '-sort -silent'
\ }

command! -nargs=? SetGopath call <sid>set_gopath(<q-args>)

fun! s:set_gopath(path)
	let path = empty(a:path) ? s:find_gopath(expand('%:p:h')) : a:path
	if !empty(path)
		let $GOPATH = path
		echo " $GOPATH set to" path
	else
		echohl WarningMsg | echo " Not inside a go project" | echohl None
	end
endf

fun! s:find_gopath(path)
	if empty(a:path) || a:path == '/'
		return ''
	end
	let files = map(globpath(a:path, "*", 1, 1), "fnamemodify(v:val, ':t')")
	if index(files, "src") >= 0 && index(files, "pkg") >= 0 && index(files, "bin") >= 0
		return a:path
	end
	return s:find_gopath(fnamemodify(a:path, ':h'))
endf
