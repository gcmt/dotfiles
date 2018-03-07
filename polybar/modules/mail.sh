#!/bin/bash

hide_notification() {
	hidden=1
	echo
}

view_mail() {
	firefox -new-tab 'https://www.fastmail.com/mail/'
	i3-msg '[class="Firefox"] focus' >/dev/null 2>&1
	echo
}

check_mail() {
	local count
	count=$(mail-check.py 2>/dev/null)
	if [[ $? -eq 0 && "$count" -gt 0 ]]; then
		if [[ $hidden -eq 0 || $hidden -eq 1 && "$count" -ne "$count_prev" ]]; then
			count_prev=$count
			hidden=0
			echo "$count"
		fi
	fi
}

trap "view_mail" SIGUSR1
trap "hide_notification" SIGUSR2

source ~/.fastmail

interval=60
count_prev=0
hidden=0
sleep_pid=

while true; do

	[[ $sleep_pid ]] && kill $sleep_pid 2>/dev/null
	sleep $interval &
	sleep_pid=$!

	wait 2>/dev/null
	if (( $? > 127 )); then
		# When SIGUSR1/SIGUSR2 is received, wait immediately returns
		# (with 138/140 exit codes)
		continue
	fi

	check_mail

done
