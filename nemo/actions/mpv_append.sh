#!/bin/bash 

fifo=/tmp/mpv.fifo

for f in "$@"; do
    echo "{\"command\": [\"loadfile\", \"${f}\", \"append\"]}" | socat - "$fifo"
done
