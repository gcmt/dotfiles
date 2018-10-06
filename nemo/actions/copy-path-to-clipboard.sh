#!/bin/bash

paths=()
while (( $# )); do
	paths+=("$1")
	shift
done

IFS=$'\n'
echo -n "${paths[*]}" | xclip -sel clipboard

(( ${#paths[*]} > 1 )) && s=s || s=
notify-send 'Path Copied' "${#paths[*]} path$s copied to the system clipboard"
