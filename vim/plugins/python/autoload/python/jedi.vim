
" INTERNAL
" -----------------------------------------------------------------------------

python << EOF
import jedi, json

_script = None

def jedi_definitions():
	return jedi_marshal(_script.goto_definitions())

def jedi_assignments():
	return jedi_marshal(_script.goto_assignments())

def jedi_usages():
	return jedi_marshal(_script.usages())

def jedi_call_signatures():
	return jedi_marshal(_script.call_signatures())

def jedi_marshal(definitions):
	data = []
	for d in definitions:
		_d = {
			'line': d.get_line_code().strip('\n'),
			'line_nr': d.line,
			'column_nr': None if d.column is None else d.column + 1,
			'module_path': d.module_path,
			'module_name': d.module_name,
			'docstring': d.docstring(raw=True),
			'description': d.description,
			'full_name': d.full_name,
			'name': d.name,
			'type': d.type,
		}
		if hasattr(d, 'params'):
			_d['params'] = [p.description.split()[1] for p in d.params if len(p.description.split()) > 1]
		data.append(_d)
	return json.dumps(data)

EOF

let s:venv = ''
let s:sys_path = ''

func s:init(sys_path)
	python _script = jedi.api.Script(
		\ path=vim.current.buffer.name,
		\ source='\n'.join(vim.current.buffer),
		\ line=vim.current.window.cursor[0],
		\ column=vim.current.window.cursor[1],
		\ sys_path=vim.eval('a:sys_path'),
		\ encoding=(vim.eval('&fenc') or vim.eval('&enc'))
	\ )
endf

func s:get_sys_path()
	if empty(s:sys_path) || $VIRTUAL_ENV != s:venv
		let s:sys_path = eval(system('python3 -c "import sys; sys.stdout.write(repr(sys.path))"'))
		let s:venv = $VIRTUAL_ENV
	end
	return s:sys_path
endf

func s:definitions(follow)
	call s:init(s:get_sys_path())
	if a:follow
		python vim.command("let json = \"{}\"".format(jedi_definitions().replace('"', '\\"')))
	else
		python vim.command("let json = \"{}\"".format(jedi_assignments().replace('"', '\\"')))
	end
	return filter(json_decode(json), 'v:val.module_path != v:null')
endf

func s:usages()
	call s:init(s:get_sys_path())
	python vim.command("let json = \"{}\"".format(jedi_usages().replace('"', '\\"')))
	return json_decode(json)
endf

func s:call_signatures()
	call s:init(s:get_sys_path())
	python vim.command("let json = \"{}\"".format(jedi_call_signatures().replace('"', '\\"')))
	return json_decode(json)
endf

func s:setqflist(definitions, ...)
	let list = []
	for def in a:definitions
		let entry = {}
		let path = substitute(def.module_path, '\V\^'.getcwd().'/', '', '')
		let entry.filename = path
		let entry.lnum = def.line_nr
		let entry.col = def.column_nr
		let entry.text = def.line
		call add(list, entry)
	endfor
	call setqflist(list, 'r')
	if a:0 > 0 && type(a:1) == v:t_dict
		call setqflist([], 'a', a:1)
	end
endf

func s:goto_definition(def, cmd) abort
	let cmd = empty(a:cmd) ? 'edit' : a:cmd
	let path = substitute(a:def.module_path, '\V\^'.getcwd().'/', '', '')
	exec cmd fnameescape(path)
	call cursor(a:def.line_nr, a:def.column_nr)
	setl cursorline
endf

func s:err(msg)
	echohl ErrorMsg | echo a:msg | echohl None
endf

" API
" -----------------------------------------------------------------------------

func python#jedi#definitions(bang, cmd) abort
	let definitions = s:definitions(1)
	if empty(definitions)
		return s:err("No definition found")
	end
	if !empty(a:bang) && len(definitions) == 1
		call s:goto_definition(definitions[0], a:cmd)
	else
		call s:setqflist(definitions, {'title': ':Definition'})
		copen
	end
endf

func python#jedi#assignments(bang, cmd) abort
	let definitions = s:definitions(0)
	if empty(definitions)
		return s:err("No assignment found")
	end
	if !empty(a:bang) && len(definitions) == 1
		call s:goto_definition(definitions[0], a:cmd)
	else
		call s:setqflist(definitions, {'title': ':Assignment'})
		copen
	end
endf

func python#jedi#usages() abort
	let usages = s:usages()
	if empty(usages)
		return s:err("Nothing found")
	end
	call s:setqflist(usages, {'title': ':Usages'})
	copen
endf

func python#jedi#docstring() abort
	let definitions = s:definitions(1)
	if empty(definitions)
		return s:err("No definition found")
	end
	let d = definitions[0]
	if !empty(d.docstring)
		echo d.docstring
	else
		call s:err("No docstring found")
	end
endf

" expected to be called in insert mode inside function parenthesis
func python#jedi#call_signatures() abort
	let definitions = s:call_signatures()
	if empty(definitions)
		call s:err("No definition found")
		return ''
	end
	let d = definitions[0]
	echo d.name . '(' . join(d.params, ', ') . ')'
	return ''
endf

" expected to be called on a function name
func python#jedi#signature() abort
	let definitions = s:definitions(1)
	if empty(definitions)
		return s:err("No definition found")
	end
	let d = definitions[0]
	if !has_key(d, 'params')
		return s:err("Not a callable")
	end
	echo d.name . '(' . join(d.params, ', ') . ')'
endf
