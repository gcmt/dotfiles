#!/bin/bash

for f in ${@}; do
    read -r W H < <(identify -format "%w %h" "${f}")
    max=$(printf "${W}\n${H}" | sort -n | tail -1)
    dunstify -r "${ID}" "SXIV" "convert -size ${max}x${max}"
    convert -size ${max}x${max} xc:white "${f}" -gravity center -composite  "${f}"
done
