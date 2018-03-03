
func! objects#python#function(inner, outermost)
	call s:select('def', a:inner, a:outermost)
endf

func! objects#python#class(inner, outermost)
	call s:select('class', a:inner, a:outermost)
endf

func! s:select(kw, inner, outermost)

	let curpos = getcurpos()[1:2]
	let wanted = a:kw == 'class' ? 'class>' : 'def>|async def>'

	if getline(curpos[0]) =~ '\v^\s*\@'
		let indent = indent(curpos[0])
		call search('\v\s{'.indent.'}(class|def|async def)>', 'W')
	end

	if getline(line('.')) =~ '\v^\s*('.wanted.')'
		let start = searchpos('\v(^$\n\zs(^\s*(\@|'.wanted.'))|%^)', 'Wbc')
	else
		let start = [0, 0]
		let indent = indent(prevnonblank(curpos[0]))
		while indent > 0
			let indent -= &shiftwidth
			let candidate = searchpos('\v^\s{'.indent.'}\w', 'Wb')
			if candidate == [0, 0]
				continue
			end
			if getline(candidate[0]) =~ '\v^\s*('.wanted.')'
				let start = searchpos('\v(^$\n\zs(^\s*(\@|'.wanted.'))|%^)', 'Wbc')
				if !a:outermost
					break
				end
			end
		endw
	end

	if start == [0, 0]
		call cursor(curpos)
		return
	end

	call cursor(start)
	let indent = indent(start[0])
	let end = searchpos('\v(^$\n\ze^\s{,'.indent.'}\S|\S%$)', 'W')

	if end == [0, 0]
		call cursor(curpos)
		return
	end

	if a:inner
		call cursor(start)
		norm! V
		call cursor(end)
		call search('\v\S', 'Wb')
	else
		call cursor(start)
		if end[0] == line('$')
			call cursor(prevnonblank(line('.')-1)+1, 1)
		end
		norm! V
		call cursor(end)
	end

endf
