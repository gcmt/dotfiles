#!/bin/bash

last_notification="/tmp/polybar-battery"

if [[ ! -f "$last_notification" ]]; then
	echo 0 > "$last_notification"
fi

is_charging() {
	acpi -b | grep -q Charging
}

# Usage: notify N message
# Don't send notification if at least N seconds haven't passed since the last notification
notify() {
	is_charging && return
	local elapsed=$(($(date +'%s') - $(cat "$last_notification")))
	if (( $elapsed > $1 )); then
		date +'%s' > "$last_notification"
		notify-send -t 10000 "Battery low" "$2"
	fi
}

charge=$(acpi -b | grep -Po '[0-9]+(?=%)')

if is_charging; then
	icon=""
elif (( $charge < 15 )); then
	notify 120 "Remaining charge:  $charge%"
	icon=""
elif (( $charge < 30 )); then
	notify 240 "Remaining charge:  $charge%"
	icon=""
elif (( $charge < 50 )); then
	icon=""
elif (( $charge < 75 )); then
	icon=""
else
	icon=""
fi

echo "$icon $charge%"
