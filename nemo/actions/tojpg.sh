#!/bin/bash

for f in "$@"; do
	convert "$f" -background white -flatten -alpha off "${f%.*}.jpg"
done
