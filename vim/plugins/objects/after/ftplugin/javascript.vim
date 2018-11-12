

if objects#enabled('javascript#function')
	call objects#mapl('ad', 'objects#javascript#function')
	call objects#mapl('id', 'objects#javascript#function', {'only_body': 1})
	call objects#mapl('ae', 'objects#javascript#function', {'include_assignment': 1})
	call objects#mapl('ie', 'objects#javascript#function', {'include_assignment': 1, 'inner': 1})
end


if objects#enabled('javascript#class')
	call objects#mapl('aD', 'objects#javascript#class')
	call objects#mapl('iD', 'objects#javascript#class', {'only_body': 1})
	call objects#mapl('aE', 'objects#javascript#class', {'include_assignment': 1})
	call objects#mapl('iE', 'objects#javascript#class', {'include_assignment': 1, 'inner': 1})
end
