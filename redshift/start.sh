#!/bin/bash

pkill -x redshift
while pgrep -x redshift >/dev/null; do sleep 1; done

redshift &
