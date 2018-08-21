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

	choice="$(echo -e "$entries" | i3-tiny-menu -format i -select "$style")"
	if [[ -z "$choice" ]]; then
		exit 1
	fi

	style="${styles[$choice]}"
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
