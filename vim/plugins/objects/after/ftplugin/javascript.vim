

if objects#enabled('javascript#function')
	call objects#mapl('af', 'objects#javascript#function')
	call objects#mapl('aF', 'objects#javascript#function', {'include_assignment': 1})
	call objects#mapl('if', 'objects#javascript#function', {'only_body': 1})
end


if objects#enabled('javascript#class')
	call objects#mapl('ac', 'objects#javascript#class')
	call objects#mapl('aC', 'objects#javascript#class', {'include_assignment': 1})
	call objects#mapl('ic', 'objects#javascript#class', {'only_body': 1})
end
