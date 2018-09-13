#!/bin/bash

dir=/run/mailcheck
count=0
count_prev=0
hidden=0
pid=

if [[ ! -d "$dir" ]]; then
	exit 1
fi

echo $$ > /tmp/polybar-mail.pid

hide_notification() {
	hidden=1
	echo
}
trap 'hide_notification' SIGUSR2

view_mail() {
	firefox -new-tab 'https://www.fastmail.com/mail/'
	i3-msg '[class="Firefox"] focus' >/dev/null 2>&1
	echo
}
trap 'view_mail' SIGUSR1

notify() {
	count=0
	for mailbox in "$dir"/*; do
		if [[ ! "$mailbox" =~ Trash|Spam|Sent|Queue|Drafts|Archive|Notes|LinkedIn|News ]]; then
			count=$(expr $count + $(cat $mailbox))
		fi
	done
	if [[ $count == 0 ]]; then
		echo
	elif [[ $hidden -eq 0 || $hidden -eq 1 && $count -ne $count_prev ]]; then
		hidden=0
		count_prev=$count
		echo "$count"
	fi
}

watch_for_updates() {
	inotifywait -qm -e close_write "$dir" |
		while read path action file; do
			notify
		done
}

notify

while true; do
	watch_for_updates & pid=$!
	wait 2>/dev/null
	kill $pid 2>/dev/null
done
