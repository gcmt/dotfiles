#!/bin/bash

charge=$(acpi -b | grep -Po '[0-9]+(?=%)')

if (( $charge < 15 )); then
	icon=""
elif (( $charge < 30 )); then
	icon=""
elif (( $charge < 50 )); then
	icon=""
elif (( $charge < 75 )); then
	icon=""
else
	icon=""
fi

echo "$icon $charge%"
