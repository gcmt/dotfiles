

if objects#enabled('python#def')
	call objects#mapl('ad', 'objects#python#def')
	call objects#mapl('id', 'objects#python#def', {'inner': 1})
end


if objects#enabled('python#class')
	call objects#mapl('aD', 'objects#python#class')
	call objects#mapl('iD', 'objects#python#class', {'inner': 1})
end
