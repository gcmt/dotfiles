

if objects#enabled('python#def')
	call objects#mapl('af', 'objects#python#def')
	call objects#mapl('if', 'objects#python#def', {'inner': 1})
end


if objects#enabled('python#class')
	call objects#mapl('ac', 'objects#python#class')
	call objects#mapl('ic', 'objects#python#class', {'inner': 1})
end
