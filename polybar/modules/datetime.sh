#!/bin/bash

utc=0

toggle() {
	utc=$((1 - $utc))
}

trap "toggle" SIGUSR1

while true; do

	if (( $utc == 1 )); then
		echo "$(date --utc '+%a %d %H:%M') UTC"
	 else
		date '+%a %d %H:%M'
	fi

	sleep 1 &
	wait

done
