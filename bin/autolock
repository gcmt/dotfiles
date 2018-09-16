#!/bin/bash

pkill -x xautolock
while pgrep -x xautolock >/dev/null; do sleep 1; done

xautolock -secure -time 30 -locker "lock -bm" &
