#!/bin/bash

killall -qw dunst
dunst &

if [[ "$1" == "-test" ]]; then
	notify-send -u critical "Title" "Critical urgency message"
	notify-send -u normal "Title" "Normal urgency message"
	notify-send -u low "Title" "Low urgency message"
fi
