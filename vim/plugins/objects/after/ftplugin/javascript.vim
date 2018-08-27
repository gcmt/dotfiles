
call objects#load_options('javascript', {
	\ 'exclude_braces': 1,
	\ 'include_comments': 1,
\ })

if objects#enabled('javascript#function')
	call objects#mapl('af', 'objects#javascript#function', 0, 0)
	call objects#mapl('aF', 'objects#javascript#function', 0, 1)
	call objects#mapl('if', 'objects#javascript#function', 1, 0)
end

if objects#enabled('javascript#class')
	call objects#mapl('ac', 'objects#javascript#class', 0, 0)
	call objects#mapl('aC', 'objects#javascript#class', 0, 1)
	call objects#mapl('ic', 'objects#javascript#class', 1, 0)
end
