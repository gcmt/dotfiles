
let s:self_closing_tags = {
	\ "img":1, "style":1, "meta": 1, "area": 1, "input": 1, "link": 1
\ }


func! s:find_tag_name(linenr, colnr)
	let braces = 0
	for linenr in reverse(range(1, a:linenr))
		let line = split(getline(linenr), '\zs')
		let line = linenr == a:linenr ? line[:(a:colnr-2)] : line
		for colnr in reverse(range(1, len(line)))
			if flow#synat(linenr, colnr) =~ 'string'
				continue
			end
			let char = line[colnr-1]
			if char == '}'
				let braces += 1
				continue
			end
			if char == '{'
				let braces -= 1
				continue
			end
			if braces
				continue
			end
			if char == "<" && !braces
				return matchstr(join(line[colnr:], ""), '\v^[a-zA-Z._]+[0-9]?>', )
			end
			if char !~ '\v[a-zA-Z0-9''"`_=. \t-]' || braces < 0
				return ""
			end
		endfo
	endfo
	return ""
endf

func! flow#tag#autoclose()
	if &ft !~ '\v(html|javascript)' || flow#synat(line('.'), col('.')) =~ 'string'
		return ">"
	end
	let before = split(flow#before(), '\zs')
	if before[-1] == "/"
		return ">"
	end
	let tagname = s:find_tag_name(line('.'), col('.'))
	if empty(tagname)
		return ">"
	end
	if get(s:self_closing_tags, tagname)
		let space = before[-1] == " " ? "" : " "
		return space . "/>"
	end
	return "></" . tagname . ">\<esc>F<i"
endf
