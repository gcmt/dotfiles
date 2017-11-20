#!/usr/bin/env sh

CACHE_DIR="$HOME/.cache/polybar/modules/battery"

mkdir -p "$CACHE_DIR"

if [ ! -f "$CACHE_DIR/last-notification" ]; then
	echo 0 > "$CACHE_DIR/last-notification"
fi

notify() {
	acpi -b | grep Charging >/dev/null 2>&1
	if [ $? -eq 0 ]; then
		return
	fi
	last_notification="$(cat $CACHE_DIR/last-notification)"
	elapsed=$(expr $(date '+%s') - $last_notification)
	if [ $elapsed -gt "$1" ]; then
		echo $(date '+%s') > "$CACHE_DIR/last-notification"
		notify-send -t 10000 'Battery low' "$2"
	fi
}

charge=$(acpi -b | grep -Po '[0-9]+(?=%)')

if [ $charge -lt "15" ]; then
	notify 120 "Remaining charge: $charge%"
	icon=""
elif [ $charge -lt "30" ]; then
	notify 240 "Remaining charge: $charge%"
	icon=""
elif [ $charge -lt "50" ]; then
	icon=""
elif [ $charge -lt "75" ]; then
	icon=""
else
	icon=""
fi

#acpi -b | grep Charging >/dev/null 2>&1
echo "$icon $charge%"
