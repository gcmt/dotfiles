#!/usr/bin/env sh

CACHE_DIR="$HOME/.cache/polybar/modules/datetime"
VERBOSITY_FILE="$CACHE_DIR/verbosity"

mkdir -p "$CACHE_DIR"

if [ ! -f "$VERBOSITY_FILE" ]; then
	echo 0 > "$VERBOSITY_FILE"
fi

VERBOSITY=$(expr 1 - $(cat "$VERBOSITY_FILE"))

if [[ "$1" == "-toggle-verbosity" ]]; then
	echo $VERBOSITY > "$VERBOSITY_FILE"
fi

if [[ $VERBOSITY == 1 ]]; then
	echo "$(date '+%a %d %b %H:%M:%S')"
else
	echo "$(date '+%a %d %b %H:%M')"
fi
