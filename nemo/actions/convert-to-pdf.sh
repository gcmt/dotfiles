#!/bin/bash

failed=()
exists=()
done=()

for file in "$@"; do
    dest="${file%.*}.pdf"
    if [[ -e "${dest}" ]]; then
        exists+=("$(basename "${dest}")")
        continue
    fi
    convert "${file}" "${dest}"
    if (( $? != 0 )); then
        failed+=("$(basename "${file}")")
    else
        done+=("$(basename "${file}")")
    fi
done

if (( ${#exists[@]} )); then
    IFS=$'\n'; notify-send -u critical "The following files already exists" "${exists[*]}"
fi

if (( ${#failed[@]} )); then
    IFS=$'\n'; notify-send -u critical "Failed to convert the following files" "${failed[*]}"
fi

if (( ${#done[@]} )); then
    notify-send -t 5000 "Convert to PDF" "${#done[@]} files successfully converted"
else
    exit 1
fi
