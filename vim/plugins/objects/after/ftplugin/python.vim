
call objects#load_options('python', {})

if objects#enabled('python#function')
	call objects#mapl('af', 'objects#python#function', 0)
	call objects#mapl('if', 'objects#python#function', 1)
end

if objects#enabled('python#class')
	call objects#mapl('ac', 'objects#python#class', 0)
	call objects#mapl('ic', 'objects#python#class', 1)
end
