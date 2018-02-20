#!/bin/bash

cache_dir="$HOME/.cache/polybar/modules/datetime"
verbosity_file="$cache_dir/verbosity"

mkdir -p "$cache_dir"

save_verbosity() {
	echo "$1" > "$verbosity_file"
}

get_verbosity() {
	cat "$verbosity_file"
}

if [[ ! -f "$verbosity_file" ]]; then
	verbosity=0
	save_verbosity $verbosity
else
	verbosity=$(get_verbosity)
fi

if [[ "$1" == "-toggle-verbosity" ]]; then
	verbosity=$(expr 1 - $verbosity)
	save_verbosity $verbosity
fi

if [[ $verbosity == 1 ]]; then
	echo "$(date '+%a %d %H:%M:%S')"
else
	echo "$(date '+%a %d %H:%M')"
fi
