#!/bin/bash

delta=$(zenity --entry --title "Resize images" --text "Enter the size change in pixel" --entry-text "100")

if [[ -z ${delta} ]]; then
    exit 1
fi

for f in ${@}; do
    read -r W H < <(identify -format "%w %h" "${f}")
    (( W += delta ))
    (( H += delta ))
    convert -size ${W}x${H} xc:white "${f}" -gravity center -composite  "${f}"
done
