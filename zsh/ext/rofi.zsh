
rofi_options() {
	colorscheme=$(xrdb -query all | grep colorscheme | grep -o '\w\+$')
	echo -n "-dmenu -monitor -2 -i -theme 'term-${colorscheme:-dark}' -width '$(rofi_width)'"
}

rofi_width() {
	(($COLUMNS < 70)) && echo 90 && return
	(($COLUMNS < 85)) && echo 80 && return
	(($COLUMNS < 100)) && echo 70 && return
	(($COLUMNS < 120)) && echo 60 && return
	echo 50
}

rofi-find() {
	local cmd='rg --files \
		-g "!*/node_modules/*" -g "!*/venv/*" -g "!dist/*" -g "!build/*"'
	local options="$(rofi_options) -p 'vim '"
	local file=$(eval "$cmd" | eval "rofi $options")
	if [[ -z "$file" ]]; then
		return 0
	fi
	BUFFER="vim '$file'"
	zle accept-line
}
zle -N rofi-find

rofi-cd() {
	local cmd='fd -td -E "!node_modules/*" -E "!venv/*" -E "!dist/*" -E "!build/*"'
	local options="$(rofi_options) -p 'cd '"
	local dir=$(eval "$cmd" | eval "rofi $options")
	if [[ -z "$dir" ]]; then
		return 0
	fi
	cd "$dir"
	zle reset-prompt
}
zle -N rofi-cd

rofi-history() {
	local options="$(rofi_options) -filter '$BUFFER' -p '$ '"
	local entry=$(fc -rnl 1 | eval "rofi $options")
	if [ -z "$entry" ]; then
		return 0
	fi
	BUFFER="$entry"
	zle vi-end-of-line
}
zle -N rofi-history
