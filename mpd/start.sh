#!/bin/bash

pkill -x mpd
while pgrep -x mpd >/dev/null; do sleep 1; done

mpd
