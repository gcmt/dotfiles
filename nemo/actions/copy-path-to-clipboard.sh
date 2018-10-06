#!/bin/bash

IFS=$'\n'
echo -n "$*" | xclip -sel clipboard

(( $# > 1 )) && s=s || s=
notify-send "Nemo" "$# path$s copied to the system clipboard"
