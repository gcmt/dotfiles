
let s:Commenter = {}

func s:Commenter.New()
	let obj = copy(self)
	let obj.wrappers = split(&cms, '\v\s*\%s\s*')
	return obj
endf

func commenter#do(type, ...) abort range
	let commenter = s:Commenter.New()
	if a:type ==# 'V' || a:type == 'n'
		call commenter.do(a:firstline, a:lastline)
	elseif a:type == 'line'
		call commenter.do(line("'["), line("']"))
	end
endf

" Comment or uncomment the given range of lines.
func s:Commenter.do(start, end) abort
	let lines = map(range(a:start, a:end), '[v:val, getline(v:val)]')
	let lines = filter(lines, "v:val[1] !~ '\\v^\\s*$'")
	let mixed = self.mixed_comments(lines)
	for [nr, line] in lines
		let line = !mixed && self.commented(line) ? self.uncomment(line) : self.comment(line)
		call setline(nr, line)
	endfor
endf

" Check if the are commented lines mixed with uncommented lines.
" If this is the case, everything is commented, even already commented lines.
func s:Commenter.mixed_comments(lines)
	let commented = 0
	for [nr, line] in a:lines
		let commented += self.commented(line) ? 1 : 0
	endfor
	return commented != len(a:lines) && commented != 0
endf

func s:Commenter.lwrapper()
	return escape(get(self.wrappers, 0, ''), '\')
endf

func s:Commenter.rwrapper()
	return escape(get(self.wrappers, 1, ''), '\')
endf

" Check if a line is commented.
func s:Commenter.commented(line)
	return a:line =~ '\V\^\s\*'.self.lwrapper().'\.\*'.self.rwrapper().'\s\*\$'
endf

" Comment a single line.
func s:Commenter.comment(line)
	let indent = matchstr(a:line, '\v^\s*')
	let code = matchstr(a:line, '\v^\s*\zs.*')
	return indent . printf(&cms, code)
endf

" Uncomment a single line.
" If there are multiple spaces between the comment leader and the
" first non-blank character, don't strip spaces
func s:Commenter.uncomment(line)
	let indent = matchstr(a:line, '\v^\s*')
	let code = matchstr(a:line, '\v^\s*\zs.*')
	if code =~ '\V\^ \*\t\+'
		" the code is indented with tabs, removes any leading space
		let code = substitute(code, '\V\^'.self.lwrapper().' \*', '', '')
	else
		" delete enough spaces to have a multiple of shiftwidth
		let spaces_num = len(matchstr(code, '\V\^'.self.lwrapper().'\zs \*'))
		let shiftwidth = &shiftwidth ? &shiftwidth : &tabstop
		let spaces = repeat(' ', spaces_num % shiftwidth)
		let code = substitute(code, '\V\^'.self.lwrapper().spaces, '', '')
	end
	let code = substitute(code, '\V\s\*'.self.rwrapper().'\s\*\$', '', '')
	return indent . code
endf
