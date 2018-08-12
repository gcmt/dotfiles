#!/bin/bash

state_file="$HOME/.local/share/polybar/datetime"

if [[ ! -e "$state_file" ]]; then
	mkdir -p "$(dirname "$state_file")"
	echo "style=default" > "$state_file"
fi

style=$(grep -Po '(?<=style=).*' "$state_file" 2>/dev/null)
style=${style:-default}

if [[ "$*" =~ -menu($| ) ]]; then

	styles=(default seconds utc)
	entries="default\\nshow seconds\\nutc time"

	rofi_options="-dmenu -format i -click-to-exit -select '$style'"
	rofi_style="-theme 'polybar.rasi' -theme-str 'window { width:15%; location:north; anchor:north; }'"

	idx=$(echo -e "$entries" | eval "rofi $rofi_options $rofi_style")
	if [[ -z "$idx" ]]; then
		exit 1
	fi

	style="${styles[$idx]}"
	sed -i "s/^style=.*/style=$style/" "$state_file"

fi

case "$style" in
	utc)
		echo "$(date --utc '+%a %d %H:%M') UTC"
		;;
	seconds)
		date '+%a %d %H:%M:%S'
		;;
	*)
		date '+%a %d %H:%M'
		;;
esac
