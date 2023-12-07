#!/bin/bash

killall -qw dunst
dunst &

if [[ "$1" == "-test" ]]; then
	notify-send -h int:value:25 -u critical "Title" "Critical urgency message"
	notify-send -h int:value:50 -u normal "Title" "Normal urgency message"
	notify-send -h int:value:75 -u low "Title" "Low urgency message"
fi
