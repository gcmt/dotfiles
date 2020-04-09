
" regtee#regtee({reg:string}) -> 0
" Start/stop/resume teeing to register `reg`
func! regtee#regtee(reg)
	if a:reg !~ '\v^[a-zA-Z]?$'
		echohl ErrorMsg | echom "Bad register name: '".a:reg."'" | echohl None
		return
	end
	if a:reg == g:regtee_register || empty(a:reg)
		let msg = !empty(g:regtee_register) ? "Stop tee @".g:regtee_register : ''
		echohl Green | echo msg | echohl None
		let g:regtee_register = ""
	elseif a:reg =~ '\u'
		echohl Green | echo "Resume tee @".a:reg | echohl None
		let g:regtee_register = tolower(a:reg)
	else
		echohl Green | echo "Start tee @".a:reg | echohl None
		let g:regtee_register = a:reg
		call setreg(a:reg, "")
	end
endf

" s:tee() -> 0
" Copy everything yanked to the unnamed register to the register named `g:regtee_register`
func! s:tee()
	let target = get(g:, "regtee_register", "")
	if empty(target) || v:event.operator != 'y' || !empty(v:event.regname) || v:event.regtype != 'v'
		return
	end
	let lines = v:event.regcontents
	" withouth this fix, the last empty line is treated as a literal \n
	let lines[-1] = lines[-1] == '\n' ? "\n" : lines[-1]
	call setreg(target, join(lines, "\n"), "a".v:event.regtype)
endf

aug _regtee
	au!
	au TextYankPost * call <sid>tee()
aug END
