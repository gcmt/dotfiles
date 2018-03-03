#!/bin/bash

last_notification=0

is_charging() {
	acpi -b | grep -q Charging
}

# usage: notify N "Message"
# Don't send notification if at least N seconds haven't passed since the last notification
notify() {
	is_charging && return
	local elapsed=$(expr $(date '+%s') - $last_notification)
	if (( $elapsed > $1 )); then
		last_notification=$(date '+%s')
		notify-send -t 10000 "Battery low" "$2"
	fi
}

while true; do

	charge=$(acpi -b | grep -Po '[0-9]+(?=%)')

	if (( $charge < 15 )); then
		notify 120 "Remaining charge:  $charge%"
		icon=""
	elif (( $charge < 30 )); then
		notify 360 "Remaining charge:  $charge%"
		icon=""
	elif (( $charge < 50 )); then
		icon=""
	elif (( $charge < 75 )); then
		icon=""
	else
		icon=""
	fi

	echo "$icon $charge%"

	sleep 60 &
	wait

done
