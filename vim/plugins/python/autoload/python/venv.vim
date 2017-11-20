
func python#venv#activate(dir)
	sil! Deactivate
	let dir = empty(a:dir) ? 'venv' : a:dir
	let venv = getcwd().'/'.dir
	if !filereadable(venv.'/bin/activate')
		return s:err("Virtual env not found: " . dir)
	end
	let $VIRTUAL_ENV = venv
	let $PATH = venv.'/bin:'.$PATH
	command! -nargs=0 Deactivate call python#venv#deactivate()
	echom "Virtual env activated:" substitute(venv, $HOME, '~', '')
endf

func python#venv#deactivate()
	if empty($VIRTUAL_ENV)
		return
	end
	echom "Virtual env deactivated:" substitute($VIRTUAL_ENV, $HOME, '~', '')
	let $PATH = substitute($PATH, '\V'.$VIRTUAL_ENV.'/bin:', '', '')
	let $VIRTUAL_ENV = ''
	sil! delcommand Deactivate
endf

func s:err(msg)
	echohl WarningMsg | echom a:msg | echohl None
endf
