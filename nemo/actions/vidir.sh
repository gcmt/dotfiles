#!/bin/bash

# current_dir is empty when using vidir from a search result
current_dir="$1"
paths=( "${@:2}" )

if [[ -d "${current_dir}" ]]; then
	cd "${current_dir}" || exit 1
    for i in "${!paths[@]}"; do
        paths[$i]=".${paths[i]#$(pwd)}"
    done
fi

exec urxvt -name floating -e vidir "${paths[@]}"
