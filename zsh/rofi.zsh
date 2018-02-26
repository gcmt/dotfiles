
rofi_options="-monitor -2 -dmenu -no-custom -i -hide-scrollbar -theme $XDG_CONFIG_HOME/rofi/themes/term-dark.theme"

rofi_width() {
	(($COLUMNS < 70)) && echo 90 && return
	(($COLUMNS < 85)) && echo 80 && return
	(($COLUMNS < 100)) && echo 70 && return
	(($COLUMNS < 120)) && echo 60 && return
	echo 50
}

rofi-find() {
	local flist=$(mktemp)
	git ls-files > "$flist" 2>/dev/null
	if [ $? -ne 0 ]; then
		rg --files -g "!node_modules/*" -g "!venv/*" -g "!dist/*" -g "!build/*" \
			-g "!*.pyc" -g "!*.beam" -g "!*.pdf" -g "!*.jpg" -g "!*.png" -g "!*.gif" -g "!*.mp4" -g "!*.mp3" \
			> "$flist"
	fi
	local file=$(cat "$flist" | eval "rofi $rofi_options -p 'vim ' -width $(rofi_width)")
	if [ -z "$file" ]; then
		return 0
	fi
	BUFFER="vim '$file'"
	zle accept-line
}
zle -N rofi-find

rofi-cd() {
	local cmd="find -L . -mindepth 1 \\( \
		-path '*/\\.*' -o -name 'node_modules' -o -name 'venv' \
		-o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \
		\\) -prune -o -type d -print 2>/dev/null | cut -b 3-"
	local dir=$(eval "$cmd" | eval "rofi $rofi_options -p 'cd ' -width $(rofi_width)")
	if [ -z "$dir" ]; then
		return 0
	fi
	BUFFER="cd '$dir'"
	zle accept-line
}
zle -N rofi-cd

rofi-history() {
	local entry=$(fc -rnl 1 | eval "rofi $rofi_options -filter '$BUFFER' -p '$ ' -width $(rofi_width)")
	if [ -z "$entry" ]; then
		return 0
	fi
	BUFFER="$entry"
	zle vi-end-of-line
}
zle -N rofi-history
