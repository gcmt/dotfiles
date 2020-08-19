
let s:bufname = '__buffers__'

" View loaded buffers in window/popup.
"
" Args:
"   - all (bool): whether or not unlisted buffers are also displayed
"
func! buffers#view(all) abort

	let buffers = s:get_buffers(a:all, g:buffers_sorting)
	if bufwinnr(s:bufname) != -1 || !len(buffers)
		return
	end

	let bufnr = bufnr(s:bufname, 1)
	call bufload(bufnr)

	call setbufvar(bufnr, '&filetype', 'buffers')
	call setbufvar(bufnr, '&buftype', 'nofile')
	call setbufvar(bufnr, '&bufhidden', 'hide')
	call setbufvar(bufnr, '&buflisted', 0)

	let table = s:render(bufnr, buffers)

	let ctx = #{
		\ bufnr: bufnr,
		\ table: table,
		\ user_bufnr: bufnr('%'),
		\ user_winnr: winnr(),
		\ all: a:all,
		\ selected: 1,
		\ is_popup: g:buffers_popup,
		\ action: '',
		\ mappings: {},
	\ }

	" position the cursor to the current buffer
	let selected = 1
	for [line, b] in items(table)
		if b == bufnr('%')
			let selected = line
			break
		end
	endfor

	if g:buffers_popup
		let ctx.mappings = extend(copy(g:buffers_mappings),
			\ get(g:, 'buffers_popup_mappings', {}))
	else
		let ctx.mappings = extend(copy(g:buffers_mappings),
			\ get(g:, 'buffers_window_mappings', {}))
	end

	let Open = g:buffers_popup ? function('s:open_popup') : function('s:open_window')
	return Open(bufnr, selected, ctx)

endf


" View the buffers list in a popup.
"
" Args:
"   - bufnr (number): the number of the buffer containing the buffers list
"   - selected (number): the line where the cursor must be placed
"   - ctx (dict): context info
"
" Returns:
"   - winid (number): the popup window id
"
func! s:open_popup(bufnr, selected, ctx)

	" Create a shared context dictionary that will be accessible in both the
	" filter and handler. The action is reset for when the popup re-created with
	" an existing context.
	let ctx = extend(copy(a:ctx), #{action: ''})

	" In order to have the highlight of the current line span the whole popup
	" width, we manage the horizontal padding ourselves (see s:render())
	let padding = [g:buffers_padding[0], 0, g:buffers_padding[2], 0]

	let winid = popup_create(a:bufnr, #{
		\ filter: function('s:popup_filter', ctx),
		\ pos: 'center',
		\ zindex: 200,
		\ wrap: 0,
		\ mapping: 0,
		\ border: [],
		\ padding: padding,
		\ cursorline: 1,
		\ borderchars: g:buffers_popup_borderchars,
		\ borderhighlight: g:buffers_popup_borderhl,
		\ highlight: g:buffers_popup_hl,
		\ maxwidth: float2nr(&columns * g:buffers_maxwidth / 100),
		\ maxheight: float2nr(&lines * g:buffers_maxheight / 100),
		\ minwidth: g:buffers_minwidth,
		\ scrollbar: g:buffers_popup_scrollbar,
		\ scrollbarhighlight: g:buffers_popup_scrollbarhl,
		\ thumbhighlight: g:buffers_popup_thumbhl,
	\ })

	" `popup-<winid>` is the sign name used by vim to highlight the selected line
	let attrs = #{linehl: g:buffers_cursorline ? g:buffers_popup_cursorlinehl : ''}
	if !empty(g:buffers_popup_indicator)
		let attrs['text'] = g:buffers_popup_indicator
		let attrs['texthl'] = g:buffers_popup_indicatorhl
	end
	call sign_define('popup-'.winid, attrs)

	" The indicator is automatically placed with a sign by vim
	if !empty(g:buffers_popup_indicator)
		call win_execute(winid, 'setl signcolumn=yes')
	end

	" Move the cursor on the nth line
	call win_execute(winid, a:selected)

	return winid
endf


" Handle popup keypresses.
"
" Args:
"   - id (number): the popup id
"   - key (string): the pressed key
"
func! s:popup_filter(id, key) dict
	let self.selected = getbufinfo(self.bufnr)[0].signs[0].lnum
	if !has_key(self.mappings, a:key)
		return popup_filter_menu(a:id, a:key)
	end
	let action = self.mappings[a:key]
	if action =~ '\v^\@'
		call s:do_action(action[1:], self, function('popup_close', [a:id]))
	elseif action =~ '\v^:'
		call win_execute(a:id, action[1:])
	else
		call s:err("Unknown action: " . action)
	end
	return 1
endf


" Execute the given action.
"
" Args:
"   - action (string): the action to perform
"   - ctx (dict): context info
"   - close_fn (func): function used to close the buffers list window or popup

func s:do_action(action, ctx, close_fn = v:none)
	let a:ctx.action = a:action
	if a:action =~ '\v^(edit|tab|split|vsplit)$'
		if s:buf_edit(a:ctx) && type(a:close_fn) == v:t_func
			call a:close_fn()
		end
	elseif a:action =~ '\v^(bdelete|bwipe|bunload)!?$'
		call s:buf_delete(a:ctx)
		if empty(a:ctx.table) && type(a:close_fn) == v:t_func
			call a:close_fn()
		end
	elseif a:action == 'toggle_unlisted'
		call s:toggle_unlisted(a:ctx)
		if empty(a:ctx.table) && type(a:close_fn) == v:t_func
			call a:close_fn()
		end
	elseif a:action =~ 'quit' || a:action =~ 'fzf'
		if type(a:close_fn) == v:t_func
			call a:close_fn()
		end
		if a:action =~ 'fzf'
			exec ":Files!"
		end
	else
		call s:err("Unknown action: " . a:action)
	end
endf


" View the buffers list in a normal window at the bottom of the screen.
"
" Args:
"   - bufnr (number): the number of the buffer containing the buffers list
"   - selected (number): the line where the cursor must be placed at start
"   - ctx (dict): context info
"
" Returns:
"   - winid (number): the window id
"
func! s:open_window(bufnr, selected, ctx)

	exec 'sil keepj keepa botright 1new' s:bufname
	let winnr = bufwinnr(s:bufname)

	call setwinvar(winnr, '&cursorline', g:buffers_cursorline)
	call setwinvar(winnr, '&cursorcolumn', 0)
	call setwinvar(winnr, '&colorcolumn', 0)
	call setwinvar(winnr, '&signcolumn', "no")
	call setwinvar(winnr, '&wrap', 0)
	call setwinvar(winnr, '&number', 0)
	call setwinvar(winnr, '&relativenumber', 0)
	call setwinvar(winnr, '&list', 0)
	call setwinvar(winnr, '&textwidth', 0)
	call setwinvar(winnr, '&undofile', 0)
	call setwinvar(winnr, '&backup', 0)
	call setwinvar(winnr, '&swapfile', 0)
	call setwinvar(winnr, '&spell', 0)

	" hide statusbar
	exec 'au BufHidden <buffer='.a:bufnr.'> let &laststatus = ' getwinvar(winnr, "&laststatus")
	call setwinvar(winnr, '&laststatus', '0')

	call s:setup_mappings(a:ctx.mappings, a:ctx)
	call s:resize_window(a:ctx, g:buffers_maxheight)

	" wipe any message
	echo

	return win_getid(winnr)

endf


" Setup mappings from the current window.
"
" Args:
"  - mappings (dict): a dictionary of mappings {lhs: rhs}
"  - ctx (dict): context info
"
func! s:setup_mappings(mappings, ctx)

	let ctx = a:ctx
	func! s:_do(action) closure
		let _ctx = extend(ctx, #{selected: line('.')})
		let Close_fn = function('win_execute', [bufwinid(_ctx.bufnr), 'close'])
		return s:do_action(a:action, _ctx, Close_fn)
	endf

	func! s:_nnoremap(lhs, rhs)
		exec "nnoremap" "<nowait> <silent> <buffer>" a:lhs a:rhs . "<cr>"
	endf

	mapclear <buffer>

	for [char, action] in items(a:mappings)
		if char =~ '\v^\\'
			let char = char[1:]
		end
		if action == '@quit'
			let action = ':close'
		elseif action == '@quit'
			let action = ':close<cr>:Files!'
		end
		if action =~ '\v^\@'
			call s:_nnoremap(char, ":call <sid>_do('".action[1:]."')")
		elseif action =~ '\v^:'
			call s:_nnoremap(char, action)
		end
	endfo

endf


" Render the buffers list in the given buffer.
"
" Args:
"  - bufnr (number): the buffer number where buffers need to be rendered
"  - buffers (list): list of buffers to render
"
" Returns:
"   - table (dict): a dictionary that maps buffer numbers to buffer lines
"
func! s:render(bufnr, buffers)

	call setbufvar(a:bufnr, "&modifiable", 1)
	sil! call deletebufline(a:bufnr, 1, "$")

	let tails = {}
	for bufnr in a:buffers
		let tail = fnamemodify(bufname(bufnr), ':t')
		let tails[tail] = get(tails, tail) + 1
	endfo

	let lpadding = g:buffers_padding[3]
	let rpadding = g:buffers_padding[1]

	" When an indicator is used, the sign column is set for the popup, but
	" only after its creation. This causes the text to shift to the right by
	" 2 columns (sign column width). This fixes the issue.
	" See s:open_popup() function.
	if !empty(g:buffers_popup_indicator)
		let rpadding += 2
	end

	let fmt = repeat(' ', lpadding) . g:buffers_line_format . repeat(' ', rpadding)

	let table = {}
	let i = 1

	for b in a:buffers

		let table[i] = b

		let is_unnamed = empty(bufname(b))
		let is_terminal = getbufvar(b, '&bt') == 'terminal'
		let is_modified = getbufvar(b, '&mod')
		let is_directory = isdirectory(bufname(b))

		let bufname = bufname(b)
		let bufdetails = ""

		if is_unnamed
			let bufname = b
			let bufdetails = g:buffers_label_unnamed
		elseif is_terminal
			let bufdetails = g:buffers_label_terminal
		else
			let bufdetails = s:prettify_path(fnamemodify(bufname, ':p'))
			let bufname =  fnamemodify(bufdetails, ':t')
			if get(tails, bufname) > 1
				let bufname = join(split(bufdetails, '/')[-2:], '/')
			end
		end

		if len(split(bufdetails, '/')) <= 1 && !is_terminal && !is_unnamed
			let bufdetails = ""
		end

		let bufdetails_prop = 'buffers_dim'
		let bufname_prop = buflisted(b) ? 'buffers_listed' : 'buffers_unlisted'
		let bufname_prop = is_modified ? 'buffers_mod' : bufname_prop
		let bufname_prop = is_terminal ? 'buffers_terminal' : bufname_prop
		let bufname_prop = is_directory ? 'buffers_directory' : bufname_prop

		let repl = #{bufname: bufname, bufdetails: bufdetails}
		let [line, positions] = util#fmt(fmt, repl, 1)
		call setbufline(a:bufnr, i, line)

		let props = #{bufname: bufname_prop, bufdetails: bufdetails_prop}
		for pos in positions
			call prop_add(i, pos[1]+1, #{end_col: pos[2]+2, type: props[pos[0]], bufnr: a:bufnr})
		endfo

		let i += 1

	endfo

	call setbufvar(a:bufnr, "&modifiable", 0)

	return table

endf


" Edit the buffer under cursor.
" The editing mode depends on the value of `a:ctx.action`.
"
" Args:
"  - ctx (dict): context info
"
func! s:buf_edit(ctx) abort

	" move to the window the user came from
	exec a:ctx.user_winnr 'wincmd w'

	let target = get(a:ctx.table, string(a:ctx.selected) , '')
	if target == a:ctx.user_bufnr
		return 1
	end

	let winid = win_getid(a:ctx.user_winnr)
	let is_terminal = getbufvar(target, '&bt') == 'terminal'

	let commands = {'tab': 'tab split', 'split': 'split', 'vsplit': 'vsplit'}
	sil exec get(commands, a:ctx.action, is_terminal ? 'split' : '')

	if is_terminal || empty(bufname(target))
		sil exec 'buffer' target
	else
		sil exec 'edit' fnameescape(bufname(target))
	end

	return 1
endf


" Delete/wipe/unload the buffer under cursor.
"
" Args:
"  - ctx (dict): context info
"
func! s:buf_delete(ctx) abort

	let target = get(a:ctx.table, string(a:ctx.selected), '')
	let buffers = sort(values(a:ctx.table), 'n')

	" select the next buffer as a replacement for every window that contains the
	" buffer `target`
	let repl = buffers[(index(buffers, target)+1) % len(buffers)]

	if repl == target
		if empty(bufname(target))
			" there are no more named buffers to switch to
			return
		end
		call win_execute(bufwinid(target), 'enew')
	else
		while bufwinid(target) != -1
			call win_execute(bufwinid(target), 'buffer ' . repl)
		endw
	end

	let is_terminal = getbufvar(target, '&buftype') == 'terminal'
	let cmd = is_terminal ? 'bwipe!' : a:ctx.action

	try
		exec cmd target
	catch /E.*/
		return s:err(matchstr(v:exception, '\vE\d+:.*'))
	endtry

	let buffers = s:get_buffers(a:ctx.all, g:buffers_sorting)
	let a:ctx.table = s:render(a:ctx.bufnr, buffers)

	if !a:ctx.is_popup
		call s:resize_window(a:ctx, g:buffers_maxheight)
	end

endf


" Toggle visibility of unlisted buffers.
"
" Args:
"  - ctx (dict): context info
"
func! s:toggle_unlisted(ctx)

	let selected_bufnr = get(a:ctx.table, string(a:ctx.selected), '')

	let a:ctx.all = 1 - a:ctx.all
	let buffers = s:get_buffers(a:ctx.all, g:buffers_sorting)
	let a:ctx.table = s:render(a:ctx.bufnr, buffers)

	" Follow the previously selected buffer
	for [line, bufnr] in items(a:ctx.table)
		if bufnr == selected_bufnr
			let a:ctx.selected = line
			break
		end
	endfo

	call win_execute(bufwinid(a:ctx.bufnr), a:ctx.selected)
	call win_execute(bufwinid(a:ctx.bufnr), 'norm! 0')

	if !a:ctx.is_popup
		call s:resize_window(a:ctx, g:buffers_maxheight)
	end

endf


" Return a list of all loaded or listed buffers.
" Buffers are sorted according to the value of g:buffers_sorting. Sorting
" defaults to numerical.
"
" Args:
"   - all (bool): if it's true, unlisted buffers are also returned
"
" Returns:
"   - buffers (list): a list of buffer numbers
"
func! s:get_buffers(all, sorting = 'numerical')
	let F1 = a:all ? function('bufexists') : function('buflisted')
	let F2 = {i, nr -> F1(nr) && getbufvar(nr, '&buftype') =~ '\v^(terminal)?$'}
	let buffers = filter(range(1, bufnr('$')), F2)
	call map(buffers, {i, b -> [b, fnamemodify(bufname(b), ':t')]})
	if a:sorting == 'alphabetical'
		call sort(buffers, {a, b -> char2nr(a[1]) - char2nr(b[1])})
	end
	return map(buffers, {i, v -> v[0]})
endf


" Prettify the given path by trimming the current working directory. If not
" successful, try to reduce file name to be relative to the home directory.
"
" Args:
"   - path (string): the path to prettify
"
" Returns:
"   - path (string): the prettified path
"
func! s:prettify_path(path)
	let repl = getcwd() != $HOME ? '\V\^'.getcwd().'/' : ''
	let path = substitute(a:path, repl, '', '')
	let path = substitute(path, '\v/$', '', '')
	let path = substitute(path, '\V\^'.$HOME, '~', '')
	return path
endf


" Resize the buffers window to fit exactly the content.
"
" Args:
"   - ctx (dict): context info
"   - max_height (number): window height as percentage of the Vim window
"
func! s:resize_window(ctx, max_height) abort

	if winnr() != bufwinnr(a:ctx.bufnr)
		return
	end

	let max = float2nr(&lines * a:max_height / 100)
	sil exec 'resize ' . min([line('$'), max])

	" push the last line to the bottom in order to not have any empty space
	call cursor(1, line('$'))
	norm! zb

	call cursor(a:ctx.selected, 1)

	" unless at the very bottom, center the cursor position
	if line('.') < (line('$') - winheight(0)/2)
		norm! zz
	end

endf


" Display a simple error message.
"
" Args:
"   - msg (string): the error message
"
func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
