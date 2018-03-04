#!/bin/bash

verbosity=0

toggle() {
	verbosity=$((1 - $verbosity))
}

trap "toggle" SIGUSR1

while true; do

	if (( $verbosity == 1 )); then
		date +'%a %d %H:%M:%S'
	else
		date +'%a %d %H:%M'
	fi

	sleep 1 &
	wait

done
