if exists("b:current_syntax")
	finish
end

syn match ledgerDate '\v^\d\d\d\d/\d\d/\d\d'
syn region ledgerCommentBlock start=/^comment/ end=/^end comment/
syn match ledgerComment /^\s*[;#].*$/

hi def link ledgerDate Bold
hi def link ledgerComment Comment
hi def link ledgerCommentBlock Comment

let b:current_syntax = "ledger"
