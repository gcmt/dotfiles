#!/bin/bash

if [[ $# -eq 1 && -d "$1" ]]; then
	cd "$1" && urxvt -name floating -e vidir
else
	urxvt -name floating -e vidir "$@"
fi
