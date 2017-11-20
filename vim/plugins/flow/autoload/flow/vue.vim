
" [firstline, lastline]
let s:template = [0, 0]
let s:script = [0, 0]
let s:style = [0, 0]

fun! flow#vue#locate_sections()
	if g:flow_disabled
		return
	end
	let s:template[0] = searchpos('\V\^<template\>', 'wnc')[0]
	let s:template[1] = searchpos('\V\^</template\>', 'wnc')[0]
	let s:script[0] = searchpos('\V\^<script\>', 'wnc')[0]
	let s:script[1] = searchpos('\V\^</script\>', 'wnc')[0]
	let s:style[0] = searchpos('\V\^<style\>', 'wnc')[0]
	let s:style[1] = searchpos('\V\^</style\>', 'wnc')[0]
endf

fun! flow#vue#space()
	let linenr = line('.')
	if linenr > s:style[0] && linenr <= s:style[1]
		return flow#css#space()
	end
	return exists('g:loaded_pairs') ? pairs#space() : ' '
endf

fun! flow#vue#newline()
	let linenr = line('.')
	if linenr > s:template[0] && linenr <= s:template[1]
		return flow#html#newline()
	end
	if linenr > s:script[0] && linenr <= s:script[1]
		return flow#javascript#newline()
	end
	if linenr > s:style[0] && linenr <= s:style[1]
		return flow#css#newline()
	end
	return "\<esc>o"
endf

fun! flow#vue#bang()
	let linenr = line('.')
	if linenr > s:template[0] && linenr <= s:template[1]
		return flow#html#bang()
	end
	return '!'
endf
