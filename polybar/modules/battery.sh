#!/bin/bash

CACHE_DIR="$HOME/.cache/polybar/modules/battery"

mkdir -p "$CACHE_DIR"

if [[ ! -f "$CACHE_DIR/last-notification" ]]; then
	echo 0 > "$CACHE_DIR/last-notification"
fi

is_charging() {
	acpi -b | grep -q Charging
}

notify_charge() {
	is_charging && return
	last_notification="$(cat $CACHE_DIR/last-notification)"
	elapsed=$(expr $(date '+%s') - $last_notification)
	if (( $elapsed > "$1" )); then
		echo $(date '+%s') > "$CACHE_DIR/last-notification"
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
