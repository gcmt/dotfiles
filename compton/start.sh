#!/bin/bash

pkill -x compton
while pgrep -x compton >/dev/null; do sleep 1; done

compton &
