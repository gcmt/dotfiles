#!/bin/bash

cache_dir="$HOME/.cache/polybar/modules/battery"

mkdir -p "$cache_dir"

if [[ ! -f "$cache_dir/last-notification" ]]; then
	echo 0 > "$cache_dir/last-notification"
fi

is_charging() {
	acpi -b | grep -q Charging
}

notify_charge() {
	is_charging && return
	last_notification="$(cat $cache_dir/last-notification)"
	elapsed=$(expr $(date '+%s') - $last_notification)
	if (( $elapsed > "$1" )); then
		echo $(date '+%s') > "$cache_dir/last-notification"
		notify-send -t 10000 "Battery low" "$2"
	fi
}

charge=$(acpi -b | grep -Po '[0-9]+(?=%)')

if (( $charge < 15 )); then
	notify_charge 120 "Remaining charge:  $charge%"
	icon=""
elif (( $charge < 30 )); then
	notify_charge 240 "Remaining charge:  $charge%"
	icon=""
elif (( $charge < 50 )); then
	icon=""
elif (( $charge < 75 )); then
	icon=""
else
	icon=""
fi

echo "$icon $charge%"
