
" [firstline, lastline]
let s:template = [0, 0]
let s:script = [0, 0]
let s:style = [0, 0]

func! autotype#vue#locate_sections()
	if g:autotype_disabled
		return
	end
	let s:template[0] = searchpos('\V\^<template\>', 'wnc')[0]
	let s:template[1] = searchpos('\V\^</template\>', 'wnc')[0]
	let s:script[0] = searchpos('\V\^<script\>', 'wnc')[0]
	let s:script[1] = searchpos('\V\^</script\>', 'wnc')[0]
	let s:style[0] = searchpos('\V\^<style\>', 'wnc')[0]
	let s:style[1] = searchpos('\V\^</style\>', 'wnc')[0]
endf

func! autotype#vue#space()
	let linenr = line('.')
	if linenr > s:style[0] && linenr <= s:style[1]
		return autotype#css#space()
	end
	return get(g:, 'loaded_pairs', 0) ? pairs#space() : ' '
endf

func! autotype#vue#newline()
	let linenr = line('.')
	if linenr > s:template[0] && linenr <= s:template[1]
		return autotype#html#newline()
	end
	if linenr > s:script[0] && linenr <= s:script[1]
		return autotype#javascript#newline()
	end
	if linenr > s:style[0] && linenr <= s:style[1]
		return autotype#css#newline()
	end
	return "\<esc>o"
endf

func! autotype#vue#bang()
	let linenr = line('.')
	if linenr > s:template[0] && linenr <= s:template[1]
		return autotype#html#bang()
	end
	return '!'
endf
