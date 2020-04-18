
let s:bufname = '__buffers__'

let s:actions = {
	\ "\<cr>": 'edit',
	\ 'l': 'edit',
	\ 'q': 'quit',
	\ 't': 'tab',
	\ 's': 'split',
	\ 'v': 'vsplit',
	\ 'a': 'toggle_unlisted',
	\ 'd': 'bdelete',
	\ 'D': 'bdelete!',
	\ 'w': 'bwipe',
	\ 'W': 'wipe!',
	\ 'u': 'bunload',
	\ 'U': 'bunload!',
\ }


" View loaded buffers in window/popup.
"
" Args:
"   - all (bool): whether or not unlisted buffers are also displayed
"
func! buffers#view(all) abort

	if bufwinnr(s:bufname) != -1 || !len(s:get_buffers(a:all))
		return
	end

	let bufnr = bufnr(s:bufname, 1)
	call bufload(bufnr)

	call setbufvar(bufnr, '&filetype', 'buffers')
	call setbufvar(bufnr, '&buftype', 'nofile')
	call setbufvar(bufnr, '&bufhidden', 'hide')
	call setbufvar(bufnr, '&buflisted', 0)

	let table = buffers#render(bufnr, a:all)

	let ctx = #{
		\ bufnr: bufnr,
		\ table: table,
		\ user_bufnr: bufnr('%'),
		\ user_winnr: winnr(),
		\ all: a:all,
		\ selected: 1,
		\ is_popup: g:buffers_popup,
		\ action: '',
	\ }

	" position the cursor to the current buffer
	let selected = 1
	for [line, b] in items(table)
		if b == bufnr('%')
			let selected = line
			break
		end
	endfor

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
	let ctx = extend(a:ctx, #{action: ''})
	" In order to have the highlight of the current line span the whole popup
	" width, we manage the horizontal padding ourselves (see buffers#render())
	let padding = [g:buffers_padding[0], 0, g:buffers_padding[2], 0]
	let winid = popup_menu(a:bufnr, #{
		\ filter: function('s:popup_filter', ctx),
		\ callback: function('s:popup_handler', ctx),
		\ borderchars: g:buffers_popup_borderchars,
		\ padding: padding,
		\ borderhighlight: g:buffers_popup_borderhl,
		\ highlight: g:buffers_popup_hl,
		\ maxwidth: float2nr(&columns * g:buffers_maxwidth / 100),
		\ maxheight: float2nr(&lines * g:buffers_maxheight / 100),
		\ minwidth: g:buffers_minwidth,
		\ scrollbar: g:buffers_popup_scrollbar,
		\ scrollbarhighlight: g:buffers_popup_scrollbarhl,
		\ thumbhighlight: g:buffers_popup_thumbhl,
		\ cursorline: g:buffers_cursorline,
		\ wrap: 0,
	\ })
	" move the cursor on the nth line
	call win_execute(winid, a:selected)
	return winid
endf


" Callback handler. Handles actions triggered by keypresses.
" Actions are set in s:popup_filter() and accessed through the shared context
" dictionary.
"
" Args:
"   - id (number): the popup id
"   - selected (number): the selected line
"
func! s:popup_handler(id, selected) dict
	let self.selected = a:selected
	if self.action =~ '\v^(edit|tab|split|vsplit)$'
		call buffers#edit(self)
	elseif self.action =~ '\v^(bdelete|bwipe|bunload)!?$'
		call buffers#delete(self)
		if len(self.table) > 0
			" keep the popup open
			call s:open_popup(self.bufnr, self.selected, self)
		end
	elseif self.action == 'toggle_unlisted'
		call buffers#toggle_unlisted(self)
		if len(self.table) > 0
			" keep the popup open
			call s:open_popup(self.bufnr, self.selected, self)
		end
	end
endf


" Handle popup keypresses.
" Set the action property in the shared context dictionary so that it can picked
" up by the callback handler.
"
" Args:
"   - id (number): the popup id
"   - key (string): the pressed key
"
func! s:popup_filter(id, key) dict
	let self.action = get(s:actions, a:key, '')
	" Make sure the popup is closed and the selected line number gets
	" passed to the handler. XXX: Need to figure out how to retrieve the
	" selected line number here...
	let key = empty(self.action) ? a:key : "\<cr>"
	return popup_filter_menu(a:id, key)
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

	call setbufvar(a:bufnr, "buffers", a:ctx)

	call s:resize_window(winnr, g:buffers_maxheight)

	" push the last line to the bottom in order to not have any empty space
	call cursor(1, line('$'))
	norm! zb

	call cursor(a:selected, 1)

	" unless at the very bottom, center the cursor position
	if line('.') < (line('$') - winheight(0)/2)
		norm! zz
	end

	" wipe any message
	echo

	return win_getid(winnr)

endf

" Render the buffers list in the given buffer.
"
" Args:
"  - bufnr (number): the buffer number where buffers need to be rendered
"  - all (bool): whether or not to also display unlisted buffers
"
" Returns:
"   - table (dict): a dictionary that maps buffer numbers to buffer lines
"
func! buffers#render(bufnr, all)

	let buffers = s:get_buffers(a:all)

	call setbufvar(a:bufnr, "&modifiable", 1)
	sil! call deletebufline(a:bufnr, 1, "$")

	let tails = {}
	for bufnr in buffers
		let tail = fnamemodify(bufname(bufnr), ':t')
		let tails[tail] = get(tails, tail) + 1
	endfo

	let table = {}

	let i = 1
	for b in buffers

		let table[i] = b

		let is_unnamed = empty(bufname(b))
		let is_terminal = getbufvar(b, '&bt') == 'terminal'
		let is_modified = getbufvar(b, '&mod')

		let name = bufname(b)

		if is_unnamed
			let name = b
			let detail = g:buffers_label_unnamed
		elseif is_terminal
			let detail = g:buffers_label_terminal
		else
			let detail = s:prettify_path(fnamemodify(name, ':p'))
			let name =  fnamemodify(detail, ':t')
			if get(tails, name) > 1
				let name = join(split(detail, '/')[-2:], '/')
			end
		end

		let lpadding = g:buffers_padding[3]
		let rpadding = g:buffers_padding[1]

		let line  = repeat(' ', lpadding)

		let name_startcol = len(line) + 1
		let name_endcol = name_startcol + len(name)
		let line .= name

		let detail_startcol = len(line) + 2
		let detail_endcol = detail_startcol + len(detail)
		if len(split(detail, '/')) > 1 || is_terminal || is_unnamed
			let line .= ' ' . detail
		end

		let line .= repeat(' ', rpadding)

		call setbufline(a:bufnr, i, line)

		if has('textprop')
			let detail_prop = 'buffers_dim'
			let name_prop = buflisted(b) ? 'buffers_listed' : 'buffers_unlisted'
			let name_prop = is_modified ? 'buffers_mod' : name_prop
			let name_prop = is_terminal ? 'buffers_terminal' : name_prop
			call prop_add(i, name_startcol, {'end_col': name_endcol, 'type': name_prop, 'bufnr': a:bufnr})
			call prop_add(i, detail_startcol, {'end_col': detail_endcol, 'type': detail_prop, 'bufnr': a:bufnr})
		end

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
func! buffers#edit(ctx) abort

	" close the buffer list
	exec 'bdelete' a:ctx.bufnr

	" move to the window the user came from
	exec a:ctx.user_winnr 'wincmd w'

	let target = get(a:ctx.table, string(a:ctx.selected) , '')
	if target == a:ctx.user_bufnr
		return
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

endf


" Delete/wipe/unload the buffer under cursor.
"
" Args:
"  - ctx (dict): context info
"
func! buffers#delete(ctx) abort

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

	let a:ctx.table = buffers#render(a:ctx.bufnr, a:ctx.all)

	if !a:ctx.is_popup
		call s:resize_window(bufwinnr(a:ctx.bufnr), g:buffers_maxheight)
		call cursor(a:ctx.selected, 1)
	end

endf


" Toggle visibility of unlisted buffers.
"
" Args:
"  - ctx (dict): context info
"
func! buffers#toggle_unlisted(ctx)

	let selected_bufnr = get(a:ctx.table, string(a:ctx.selected), '')

	let a:ctx.all = 1 - a:ctx.all
	let a:ctx.table = buffers#render(a:ctx.bufnr, a:ctx.all)

	" Follow the previously selected buffer
	for [line, bufnr] in items(a:ctx.table)
		if bufnr == selected_bufnr
			let a:ctx.selected = line
			break
		end
	endfo

	call win_execute(bufwinid(a:ctx.bufnr), a:ctx.selected."|norm! 0")

	if !a:ctx.is_popup
		call s:resize_window(bufwinnr(a:ctx.bufnr), g:buffers_maxheight)
	end

endf


" Return a list of loaded buffers.
"
" Args:
"   - all (bool): if it's given and it's true, unlisted buffers are also returned
"
" Returns:
"   - buffers (list): a list of buffer numbers
"
func! s:get_buffers(...)
	let F1 = a:0 > 0 && a:1 ? function('bufexists') : function('buflisted')
	let F2 = {i, nr -> F1(nr) && getbufvar(nr, '&buftype') =~ '\v^(terminal)?$'}
	return filter(range(1, bufnr('$')), F2)
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
	let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
	let path = substitute(path, '\V\^'.$HOME, '~', '')
	return path
endf


" Resize a window to fit exactly the buffer content.
"
" Args:
"   - winnr (number): the target window number
"   - max_height (number): window height as percentage of the Vim window
"
func! s:resize_window(winnr, max_height)
	let winid = win_getid(a:winnr)
	let max = float2nr(&lines * a:max_height / 100)
	call win_execute(winid, 'resize ' . min([line('$'), max]), 1)
endf


" Display a simple error message.
"
" Args:
"   - msg (string): the error message
"
func! s:err(msg)
	echohl WarningMsg | echo a:msg | echohl None
endf
