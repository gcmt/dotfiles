#!/bin/bash

if [[ -d "$1" ]]; then
	current="$1"
	cd "$1" || exit 1
	shift
	if [[ "$2" == "$current" ]]; then
		shift
	fi
else
	exit 1
fi

args=( "$@" )
for i in "${!args[@]}"; do
	args[$i]=".${args[i]#$current}"
done

exec urxvt -name floating -e vidir "${args[@]}"
