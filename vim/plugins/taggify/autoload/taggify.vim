
func! taggify#expand(inline)
    let col = col(".")-1
    let line = getline(".")
    " search for the start of the trigger
    let [_, start] = searchpos('\V\(\[^a-z0-9#._-]\)\@<=\.', "nb", line("."))
    let start = start == 0 ? 1 : start
    if start > 0
        " exctract the text to expand
        let trigger = line[(start-1):(col-1)]
        " remove the trigger from the current line
        cal setline(line("."), strpart(line, 0, start-1) . strpart(line, col))
        " move the cursor at the position where the expansion should be placed
        cal cursor(line("."), start)
        " extract the tag name, id, and classes form the trigger
        let [tag, id, classes] = s:parse_trigger(trigger)
        " render id and classes if any
        let attrs = []
        if !empty(id)
            call insert(attrs, ["id", id])
        endif
        if !empty(classes)
            call insert(attrs, ["class", classes])
        endif
        if tag == "a"
            call insert(attrs, ["href", ""])
        endif
        " insert a multiline tag if requested
        let multiline = a:inline ? "" : "\<CR>\<ESC>O"
        " calculate movements required to move inside the expanded tag
        let moveback = "\<ESC>" . repeat("h", len(tag)+2+1) . "i"
        " expand the trigger
        return "<" . tag . s:render_attrs(attrs) . "></" . tag . ">" . moveback . multiline
    end
    return ""
endf

" To extract the tag name, id, and classes form the trigger
func! s:parse_trigger(trigger)
    let [tag, id, classes] = ["", "", []]
    let tokens = split(a:trigger, '\V\ze.\|\ze#')
    for i in range(len(tokens))
        if i == 0
            let tag = tokens[i]
        elseif tokens[i] =~ '\V\^.\.\+'
            let classes = add(classes, tokens[i][1:])
        elseif tokens[i] =~ '\V\^#\.\+'
            let id = tokens[i][1:]
        end
    endfor
    return [tag, id, classes]
endf

" To render tag attributes
func! s:render_attrs(attrs)
    let out = ""
    for [key, val] in a:attrs
        let out .= printf(" %s='%s'", key, type(val) == type([]) ? join(val) : val)
    endfor
    return out
endf
