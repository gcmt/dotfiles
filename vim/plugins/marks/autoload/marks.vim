

let s:bufname = '__marks__'


" Automatically mark the current line.
" If the mark already exists, it is deleted.
"
" Args:
"   - local (bool) -> whether or not the marks should be local to the current
"   buffer (a lowercase letter is used to set the mark)
"
func marks#set_auto(local) abort

	let marks = s:get_marks(bufnr('%'))
	let bufpath = fnamemodify(bufname('%'), ':p')

	" Check if the mark is already set on the current line and if so, delete it
	for mark in values(marks)
		if mark.file ==# bufpath && mark.linenr == line('.') && mark.line ==# getline('.')
			exec 'delmarks' mark.letter
			echo printf("line \"%s\" unmarked [%s]", line('.'), mark.letter)
			return
		end
	endfo

	let letters = a:local ? 'abcdefghijklmnopqrstuvwxyz' : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	for letter in split(letters, '\ze')
		if !has_key(marks, letter)
			exec 'mark' letter
			echo printf("line \"%s\" marked with [%s]", line('.'), letter)
			return
		end
	endfo

	call s:err("No more marks available")
endf

" Open the buffer where marks will be displayed
func marks#view() abort

	let marks = s:get_marks(bufnr('%'))
	if bufwinnr(s:bufname) != -1
		return
	end

	let bufnr = bufnr(s:bufname, 1)
	call bufload(bufnr)

	call setbufvar(bufnr, '&filetype', 'marks')
	call setbufvar(bufnr, '&buftype', 'nofile')
	call setbufvar(bufnr, '&bufhidden', 'hide')
	call setbufvar(bufnr, '&buflisted', 0)

	let table = s:render(bufnr, marks)

	let ctx = #{
		\ bufnr: bufnr,
		\ table: table,
		\ user_bufnr: bufnr('%'),
		\ user_winnr: winnr(),
		\ selected: 1,
		\ is_popup: g:marks_popup,
		\ action: '',
		\ mappings: {},
	\ }

	" position the cursor to the current buffer
	let current_file = fnamemodify(bufname('%'), ':p')
	for [line, m] in items(table)
		if type(m) == v:t_string && m ==# current_file
			let ctx.selected = line
			break
		end
	endfor

	if g:marks_popup
		let ctx.mappings = extend(copy(g:marks_mappings),
			\ get(g:, 'marks_popup_mappings', {}))
	else
		let ctx.mappings = extend(copy(g:marks_mappings),
			\ get(g:, 'marks_window_mappings', {}))
	end

	let Open = g:marks_popup ? function('s:open_popup') : function('s:open_window')
	return Open(bufnr, ctx)

endf


" View marks in a popup.
"
" Args:
"   - bufnr (number): the number of the buffer where marks are rendered
"   - ctx (dict): context info
"
" Returns:
"   - winid (number): the popup window id
"
func s:open_popup(bufnr, ctx) abort

	" In order to have the highlighting of the current line span the whole popup
	" width, we manage the horizontal padding ourselves in the s:render()
	" function
	let padding = [g:marks_padding[0], 0, g:marks_padding[2], 0]

	let winid = popup_create(a:bufnr, #{
		\ filter: function('s:popup_filter', a:ctx),
		\ pos: 'center',
		\ zindex: 200,
		\ wrap: 0,
		\ mapping: 0,
		\ border: [],
		\ padding: padding,
		\ cursorline: 1,
		\ borderchars: g:marks_popup_borderchars,
		\ borderhighlight: g:marks_popup_borderhl,
		\ highlight: g:marks_popup_hl,
		\ maxwidth: float2nr(&columns * g:marks_maxwidth / 100),
		\ maxheight: float2nr(&lines * g:marks_maxheight / 100),
		\ minwidth: g:marks_minwidth,
		\ scrollbar: g:marks_popup_scrollbar,
		\ scrollbarhighlight: g:marks_popup_scrollbarhl,
		\ thumbhighlight: g:marks_popup_thumbhl,
	\ })

	" `popup-<winid>` is the sign name used by vim to highlight the selected line
	let attrs = #{linehl: g:marks_cursorline ? g:marks_popup_cursorlinehl : ''}
	if !empty(g:marks_popup_indicator)
		let attrs['text'] = g:marks_popup_indicator
		let attrs['texthl'] = g:marks_popup_indicatorhl
	end
	call sign_define('popup-'.winid, attrs)

	" The indicator is automatically placed with a sign by vim
	if !empty(g:marks_popup_indicator)
		call win_execute(winid, 'setl signcolumn=yes')
	end

	" Move the cursor on the nth line
	call win_execute(winid, a:ctx.selected)

	return winid
endf


" Handle popup keypresses.
"
" Args:
"   - id (number): the popup id
"   - key (string): the pressed key
"
func s:popup_filter(id, key) dict abort

	" Retrieve the cursor line number.
	" (a sign is automatically placed by Vim on the current line)
	let self.selected = getbufinfo(self.bufnr)[0].signs[0].lnum

	" Key is not handled
	if !has_key(self.mappings, a:key)
		return popup_filter_menu(a:id, a:key)
	end

	let action = self.mappings[a:key]
	if action =~ '\v^\@'
		if s:do_action(action[1:], self)
			call popup_close(a:id)
		end
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

func s:do_action(action, ctx) abort
	let a:ctx.action = a:action
	if a:action =~ '\v^(jump|tab|split|vsplit)$'
		return s:mark_jump(a:ctx)
	elseif a:action == 'delete'
		return s:mark_del(a:ctx)
	elseif a:action == 'quit'
		return 1
	else
		call s:err("Unknown action: " . a:action)
	end
endf


" View the marks in a normal window at the bottom of the screen.
"
" Args:
"   - bufnr (number): the number of the buffer containing rendered marks
"   - ctx (dict): context info
"
" Returns:
"   - winid (number): the window id
"
func s:open_window(bufnr, ctx) abort

	exec 'sil keepj keepa botright 1new' s:bufname
	let winnr = bufwinnr(s:bufname)

	call setwinvar(winnr, '&cursorline', g:marks_cursorline)
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

	call s:setup_mappings(a:ctx)
	call s:resize_window(a:ctx, g:marks_maxheight)

	" wipe any message
	echo

	return win_getid(winnr)

endf


" Setup mappings from the current window.
"
" Args:
"  - ctx (dict): context info containing mappings
"
func s:setup_mappings(ctx) abort

	let ctx = a:ctx
	func! s:_do(action) closure abort
		let _ctx = extend(ctx, #{selected: line('.')})
		if s:do_action(a:action, _ctx)
			call win_execute(bufwinid(a:ctx.bufnr), 'close')
		end
	endf

	func! s:_nnoremap(lhs, rhs) abort
		exec "nnoremap" "<nowait> <silent> <buffer>" a:lhs a:rhs . "<cr>"
	endf

	mapclear <buffer>

	for [char, action] in items(a:ctx.mappings)
		if char =~ '\v^\\'
			let char = char[1:]
		end
		if action =~ '\v^\@'
			call s:_nnoremap(char, ":call <sid>_do('".action[1:]."')")
		elseif action =~ '\v^:'
			call s:_nnoremap(char, action)
		end
	endfo

endf


" Set text properties for the given positions
"
" Args:
"  - bufnr (number): the buffer where text properties needs to be attached
"  - marks (dict): the line number where text properties needs to be attached
"  - positions (list): list text property types/positions
"    eg. [prop_type, start_col, end_col]
"  - prefix (string): string used for prefixing text property types
"
func! s:setprops(bufnr, linenr, positions, prefix = "marks_")
	for pos in a:positions
		call prop_add(a:linenr, pos[1]+1, #{
			\ end_col: pos[2]+2, type: a:prefix..pos[0],
			\ bufnr: a:bufnr
		\ })
	endfo
endf


" Render marks in the given buffer.
"
" Args:
"  - bufnr (number): the buffer number where rendering needs to happen
"  - marks (dict): marks to be rendered
"
" Returns:
"   - table (dict): a dictionary that maps buffer lines to marks
"
func s:render(bufnr, marks) abort

	let links = ['├', '└', '─']

	call setbufvar(a:bufnr, "&modifiable", 1)
	sil! call deletebufline(a:bufnr, 1, "$")

	let lpadding = g:buffers_padding[3]
	let rpadding = g:buffers_padding[1]

	" When an indicator is used, the sign column is set for the popup, but
	" only after its creation. This causes the text to shift to the right by
	" 2 columns (sign column width). This fixes the issue.
	" See s:open_popup() function.
	if !empty(g:buffers_popup_indicator)
		let rpadding += 2
	end

	if empty(a:marks)
		call setbufline(a:bufnr, 1, repeat(' ', lpadding) . "No marks set")
		return {}
	end

	let fmtmark = repeat(' ', lpadding) . g:marks_mark_format . repeat(' ', rpadding)
	let fmtfile = repeat(' ', lpadding) . g:marks_file_format . repeat(' ', rpadding)

	let table = {}
	let i = 1

	for [path, marks] in items(s:group_by_file(a:marks))

		let table[i] = path
		let repl = #{file: s:prettify_path(path)}
		let [line, positions] = util#fmt(fmtfile, repl, 1)
		call setbufline(a:bufnr, i, line)
		call s:setprops(a:bufnr, i, positions)

		let i += 1
		let k = 0

		let ln_width = len(max(map(copy(marks), {k, v -> v.linenr})))
		let col_width = len(max(map(copy(marks), {k, v -> v.colnr})))

		for mark in sort(marks, {a, b -> a.linenr - b.linenr})
			let table[i] = mark
			let repl = #{
				\ link: k == len(marks)-1 ? links[1].links[2] : links[0].links[2],
				\ mark: mark.letter,
				\ linenr: printf('%'.ln_width.'S', mark.linenr),
				\ colnr: printf('%'.col_width.'S', mark.colnr),
				\ line: printf('%s', trim(mark.line)),
			\ }
			let [line, positions] = util#fmt(fmtmark, repl, 1)
			call setbufline(a:bufnr, i, line)
			call s:setprops(a:bufnr, i, positions)

			let i += 1
			let k += 1
		endfo

	endfo

	call setbufvar(a:bufnr, "&modifiable", 0)

	return table
endf


" Jump to the selected mark.
"
" Args:
"  - ctx (dict): context info
"
func s:mark_jump(ctx) abort

	let mark = s:get_selected_mark(a:ctx)
	if empty(mark) || type(mark) == v:t_string
		return 0
	end

	exec a:ctx.user_winnr . 'wincmd w'
	sil! exec bufwinnr(a:ctx.bufnr) . 'wincmd c'

	if a:ctx.action =~ '\vv?split$'
		exec a:ctx.action
	elseif a:ctx.action == 'tab'
		exec 'tab split'
	end

	exec 'norm! `' . mark.letter
	norm! zz

	return 1
endf


" Delete the selected mark.
"
" Args:
"  - ctx (dict): context info
"
func s:mark_del(ctx) abort

	let mark = s:get_selected_mark(a:ctx)
	if empty(mark) || type(mark) == v:t_string
		return 0
	end

	let cmd = 'delmarks ' .. mark.letter
	call win_execute(bufwinid(a:ctx.user_bufnr), cmd)

	let marks = s:get_marks(a:ctx.user_bufnr)
	let a:ctx.table = s:render(a:ctx.bufnr, marks)
	call s:resize_window(a:ctx, g:marks_maxheight)

	return 0
endf


" Return all [a-zA-Z] marks.
"
" Returns:
"   - marks (dict): all defined marks
"
func s:get_marks(bufnr) abort
	let winid = bufwinid(a:bufnr)
	if winid == -1
		call s:err("Buffer not visible: " .. a:bufnr)
		return {}
	end
	let marks = {}
	for line in split(win_execute(winid, 'marks'), "\n")[1:]
		let match = matchlist(line, '\v\s([a-zA-Z])\s+(\d+)\s+(\d+)\s+(.*)')
		if empty(match)
			continue
		end
		let mark = #{letter: match[1], linenr: str2nr(match[2]), colnr: str2nr(match[3])}
		let path = fnamemodify(match[4], ':p')
		let mark.file = filereadable(path) ? path : fnamemodify(bufname(a:bufnr), ':p')
		let mark.line = get(getbufline(mark.file, mark.linenr), 0, '')
		let marks[match[1]] = mark
	endfo
	return marks
endf


" Group marks by the file they belong to.
"
" Args:
"   - marks (dict): marks to be grouped
"
" Returns:
"   - marks (dict): marks grouped by file
"
func s:group_by_file(marks) abort
	let groups = {}
	for mark in values(a:marks)
		if !has_key(groups, mark.file)
			let groups[mark.file] = []
		end
		call add(groups[mark.file], mark)
	endfo
	return groups
endf


" Resize the current window.
"
" Args:
"   - ctx (dict): context info
"   - max_height (number): the maximum window height as apercentage of the Vim
"   window total height
"
func s:resize_window(ctx, max_height) abort

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


" Returns the currently selected mark.
"
" Args:
"   - ctx (dict): context info
"
" Returns:
"   - mark (dict): the selected mark or and empty dictionary
"
func s:get_selected_mark(ctx)
	return get(a:ctx.table, string(a:ctx.selected), {})
endf


" Prettify the given path.
" Wherever possible, trim the current working directory.
"
" Args:
"   - path (string): the path to prettify
"
" Returns:
"   - path (string): the prettified path
"
func s:prettify_path(path) abort
	let path = substitute(a:path, getcwd() != $HOME ? '\V\^'.getcwd().'/' : '', '', '')
	return substitute(path, '\V\^'.$HOME, '~', '')
endf


" Show a simple error message.
"
func s:err(fmt, ...) abort
	echohl WarningMsg | echom call('printf', [a:fmt] + a:000)  | echohl None
endf
