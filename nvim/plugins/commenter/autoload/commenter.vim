
let s:Commenter = {}

func! s:Commenter(start, end)
    let obj = copy(s:Commenter)
    let obj.start = a:start
    let obj.end = a:end
    let obj.wrappers = split(&cms, '\v\s*\%s\s*')
    return obj
endf

func! commenter#toggle_op(type, ...) abort range
    if a:type ==# 'V' || a:type == 'n'
        call commenter#toggle(a:firstline, a:lastline)
    elseif a:type == 'line'
        call commenter#toggle(line("'["), line("']"))
    end
endf

func! commenter#toggle(start, end) abort
    call s:Commenter(a:start, a:end).toggle()
endf

func! commenter#comment(start, end) abort
    call s:Commenter(a:start, a:end).comment()
endf

func! commenter#uncomment(start, end) abort
    call s:Commenter(a:start, a:end).uncomment()
endf

func! s:Commenter.comment() abort
    let lines = self.lines()
    let mixed = self.mixed(lines)
    for [nr, line] in lines
        if self.commented(line)
            if mixed
                call setline(nr, self.comment_line(line))
            end
        else
            call setline(nr, self.comment_line(line))
        end
    endfo
endf

func! s:Commenter.uncomment() abort
    let lines = self.lines()
    for [nr, line] in lines
        call setline(nr, self.uncomment_line(line))
    endfo
endf

func! s:Commenter.toggle() abort
    let lines = self.lines()
    let mixed = self.mixed(lines)
    for [nr, line] in lines
        if !mixed && self.commented(line)
            call setline(nr, self.uncomment_line(line))
        else
            call setline(nr, self.comment_line(line))
        end
    endfo
endf

" Get list of lines to comment as [ [linenr, line], .. ]
func! s:Commenter.lines()
    let lines = map(range(self.start, self.end), {i, val -> [v:val, getline(v:val)]})
    let lines = filter(lines, {i, val -> val[1] !~ '\v^\s*$'})
    return lines
endf

" Check if the are commented lines mixed with uncommented lines.
func! s:Commenter.mixed(lines)
    let commented = 0
    for [nr, line] in a:lines
        let commented += self.commented(line) ? 1 : 0
    endfor
    return commented != len(a:lines) && commented != 0
endf

func! s:Commenter.lwrapper()
    return escape(get(self.wrappers, 0, ''), '\')
endf

func! s:Commenter.rwrapper()
    return escape(get(self.wrappers, 1, ''), '\')
endf

" Check if a line is commented.
func! s:Commenter.commented(line)
    return a:line =~ '\V\^\s\*'.self.lwrapper().'\.\*'.self.rwrapper().'\s\*\$'
endf

" Comment a single line.
func! s:Commenter.comment_line(line)
    let indent = matchstr(a:line, '\v^\s*')
    let code = matchstr(a:line, '\v^\s*\zs.*')
    return indent . printf(&cms, code)
endf

" Uncomment a single line.
" If there are multiple spaces between the comment leader and the
" first non-blank character, don't strip spaces
func! s:Commenter.uncomment_line(line)
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
