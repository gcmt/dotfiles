

let s:default_options = {
    \ 'inner': 0,
\ }


func! objects#items#args(options, visual, count)
    call s:select('(', s:options(a:options), a:visual, a:count)
endf


func! objects#items#list(options, visual, count)
    call s:select('[', s:options(a:options), a:visual, a:count)
endf


func! objects#items#dict(options, visual, count)
    call s:select('{', s:options(a:options), a:visual, a:count)
endf


func! s:options(options)
    let globals = get(g:objects_options, 'items', {})
    return objects#merge_dicts(s:default_options, globals, a:options)
endf


func! s:select(type, options, visual, count) abort

    let curpos = getcurpos()[1:2]

    let list_start = [0, 0]
    let list_end = [0, 0]
    let skip = "objects#synat(line('.'), col('.')) =~ '\\v^(String|Comment)$'"
    let pairs = {'(': ')', '[': ']', '{': '}'}

    for i in range(1, a:count)
        if searchpair('\V'.a:type, '', '\V'.pairs[a:type], 'Wb', skip, line('w0'))
            let list_start = getcurpos()[1:2]
            norm! %
            let list_end = getcurpos()[1:2]
            call cursor(list_start)
            if list_start == list_end
                let list_start = [0, 0]
                break
            end
        else
            break
        end
    endfo

    call cursor(curpos)

    if list_start == [0, 0]
        return
    end

    let item_start = list_start
    let item_end = list_end
    let stack = []
    let stop = 0

    for nr in range(list_start[0], list_end[0])

        let line = getline(nr)
        let start_i = nr == list_start[0] ? list_start[1]+1 : 1
        let end_i = nr == list_end[0] ? list_end[1]-1 : len(line)
        if start_i > len(line) || end_i == 0
            continue
        end

        for i in range(start_i, end_i)

            if objects#synat(nr, i) =~ '\v^(String|Comment)$'
                continue
            end

            let char = line[i-1]

            if char == ',' && empty(stack)
                if nr < curpos[0] || nr == curpos[0] && i <= curpos[1]
                    let item_start = [nr, i]
                    continue
                end
                if nr > curpos[0] || nr == curpos[0] && i >= curpos[1]
                    let item_end = [nr, i]
                    let stop = 1
                    break
                end
            end

            if has_key(pairs, char)
                call add(stack, char)
            elseif get(pairs, get(stack, -1, ''), '') == char
                call remove(stack, -1)
            end

        endfo

        if stop
            break
        end

    endfo

    " Do nothing when there is no argument/item/etc, not even empty space
    if list_start[0] == list_end[0] && list_start[1] == list_end[1]-1
        return
    end

    if item_start == list_start && item_end == list_end
        call cursor(item_start[0], item_start[1])
        call search('\S', 'W')
        if getcurpos()[1:2] == list_end
            " when there is no argument/item/etc but only empty space
            call cursor(item_start[0], item_start[1]+1)
        end
        norm! v
        call cursor(item_end[0], item_end[1])
        call search('\S', 'Wb')
        if getcurpos()[1:2] == list_start
            " when there is no argument/item/etc but only empty space
            call cursor(item_end[0], item_end[1]-1)
        end
        return
    end

    if item_end == list_end
        call cursor(item_end[0], item_end[1])
        call search('\S', 'Wb')
        norm! v
        call cursor(item_start[0], item_start[1])
        if a:options.inner
            call search('\S', 'W')
        end
        return
    end

    call cursor(item_start[0], item_start[1])
    call search('\S', 'W')
    norm! v
    call cursor(item_end[0], item_end[1])
    if a:options.inner
        call search('\S', 'Wb')
    else
        call search('\v(,|\s)\S', 'Wc')
        if strpart(getline('.'), col('.')-1, 1) == "\t"
            norm! l
        end
    end

endf
