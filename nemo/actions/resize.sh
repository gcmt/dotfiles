#!/bin/bash

size=$(zenity --entry --title "Scale images" --text "Enter the size in pixel" --entry-text "1000")

if [[ -z ${size} ]]; then
    exit 1
fi

for f in ${@}; do
    convert -resize ${size}x${size} "${f}" "${f}"
done
