#!/bin/bash

timer="$HOME/.cache/timer"
verbosity=0

toggle() {
	verbosity=$((1 - $verbosity))
}

trap "toggle" SIGUSR1

while true; do

	padding="  "
	if [[ -e "$timer" ]]; then
		padding=
	fi

	if (( $verbosity == 1 )); then
		echo "$(date +'%a %d %H:%M:%S')$padding"
	else
		echo "$(date +'%a %d %H:%M')$padding"
	fi

	sleep 1 &
	wait

done
