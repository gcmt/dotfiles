
func! autotype#vue#setup()
	inoremap <silent> <buffer> <space> <c-]><c-g>u<c-r>=autotype#vue#space()<cr>
	inoremap <silent> <buffer> <c-d> <c-]><c-g>u<c-r>=autotype#vue#esc_o()<cr>
	inoremap <silent> <buffer> ! <c-]><c-g>u<c-r>=autotype#vue#bang()<cr>
endf

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
	let Space = {-> exists('*pairs#space') ? pairs#space() : ' '}
	if linenr > s:style[0] && linenr <= s:style[1]
		return autotype#css#space()
	end
	return Space()
endf

func! autotype#vue#esc_o()
	let linenr = line('.')
	if linenr > s:template[0] && linenr <= s:template[1]
		return autotype#html#newline()
	end
	if linenr > s:script[0] && linenr <= s:script[1]
		return autotype#javascript#esc_o()
	end
	if linenr > s:style[0] && linenr <= s:style[1]
		return autotype#css#esc_o()
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
