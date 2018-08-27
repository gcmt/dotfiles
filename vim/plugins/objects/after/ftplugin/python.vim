

if objects#enabled('python#function')
	call objects#mapl('af', 'objects#python#function')
	call objects#mapl('if', 'objects#python#function', {'inner': 1})
end


if objects#enabled('python#class')
	call objects#mapl('ac', 'objects#python#class')
	call objects#mapl('ic', 'objects#python#class', {'inner': 1})
end
