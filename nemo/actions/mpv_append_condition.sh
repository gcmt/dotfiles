#!/bin/bash

if [ -e /tmp/mpv.fifo ]
then
    exit 0
else
    exit 1
fi
