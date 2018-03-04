#!/bin/bash

timer="/tmp/timer"

stop_timer() {
	rm -f "$timer"
}

trap "stop_timer" SIGUSR1

while true; do

	if [[ -e "$timer" ]]; then
		seconds=$(expr $(cat "$timer") - $(date +'%s'))
		if (( $seconds < 0 )); then
			notify-send 'Timer' 'Timer finished!'
			stop_timer
		else
			if (( $seconds > 60 * 60 )); then
				date -u -d @${seconds} +'%H:%M:%S'
			else
				date -u -d @${seconds} +'%M:%S'
			fi
		fi
	else
		echo
	fi

	sleep 1 &
	wait

done
