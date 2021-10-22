#!/bin/bash

size=$(zenity --entry --title "Resize images" --text "Enter the size in pixel" --entry-text "800")

if [[ -z ${size} ]]; then
    exit 1
fi

for f in ${@}; do
    convert -size ${size}x${size} xc:white "${f}" -gravity center -composite  "${f}"
done
