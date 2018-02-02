
python3 << EOF

import jedi

_jedi_script = None

def jedi_definitions():
	return jedi_marshal(_jedi_script.goto_definitions())

def jedi_assignments():
	return jedi_marshal(_jedi_script.goto_assignments())

def jedi_usages():
	return jedi_marshal(_jedi_script.usages())

def jedi_call_signatures():
	return jedi_marshal(_jedi_script.call_signatures())

def jedi_marshal(definitions):
	rv = []

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
			_d['params'] = []
			for param in d.params:
				if len(param.description.split()) > 1:
					_d['params'] = param.description.split()[1]

		rv.append(_d)

	return rv

EOF

let s:Jedi = {}

func s:Jedi.New()
	let obj = copy(self)
	let obj.venv = ''
	let obj.sys_path = ''
	return obj
endf

func s:Jedi.pyeval(expr)
	call self.init_jedi_script()
	return py3eval(a:expr)
endf

func s:Jedi.init_jedi_script()
	call self.update_sys_path()
	python3 _jedi_script = jedi.api.Script(
		\ path=vim.current.buffer.name,
		\ source='\n'.join(vim.current.buffer),
		\ line=vim.current.window.cursor[0],
		\ column=vim.current.window.cursor[1],
		\ sys_path=vim.eval('self.sys_path'),
		\ encoding=(vim.eval('&fenc') or vim.eval('&enc'))
	\ )
endf

func s:Jedi.update_sys_path()
	if empty(self.sys_path) || $VIRTUAL_ENV != self.venv
		let self.sys_path = eval(system('python3 -c "import sys; sys.stdout.write(repr(sys.path))"'))
		let self.venv = $VIRTUAL_ENV
	end
endf

func s:Jedi.definitions(follow)
	let res = self.pyeval(a:follow ? 'jedi_definitions()' : 'jedi_assignments()')
	return filter(res, 'v:val.module_path != v:none')
endf

func s:Jedi.usages()
	return self.pyeval('jedi_usages()')
endf

func s:Jedi.call_signatures()
	return self.pyeval('jedi_call_signatures()')
endf

" API
" -----------------------------------------------------------------------------

let s:jedi = s:Jedi.New()

func s:err(msg)
	echohl ErrorMsg | echo a:msg | echohl None
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

func python#jedi#definitions(bang, cmd) abort
	let definitions = s:jedi.definitions(1)
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
	let definitions = s:jedi.definitions(0)
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
	let usages = s:jedi.usages()
	if empty(usages)
		return s:err("Nothing found")
	end
	call s:setqflist(usages, {'title': ':Usages'})
	copen
endf

func python#jedi#docstring() abort
	let definitions = s:jedi.definitions(1)
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
	let definitions = s:jedi.call_signatures()
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
	let definitions = s:jedi.definitions(1)
	if empty(definitions)
		return s:err("No definition found")
	end
	let d = definitions[0]
	if !has_key(d, 'params')
		return s:err("Not a callable")
	end
	echo d.name . '(' . join(d.params, ', ') . ')'
endf
