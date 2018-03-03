#!/bin/bash

timer="$HOME/.cache/timer"

while true; do

	if [[ -e "$timer" ]]; then
		seconds=$(expr $(cat "$timer") - $(date +'%s'))
		if (( $seconds < 0 )); then
			rm "$timer"
			notify-send 'Timer' 'Timer Finished!'
		else
			date -u -d @${seconds} +'%M:%S'
		fi
	else
		echo
	fi

	sleep 1 &
	wait

done
