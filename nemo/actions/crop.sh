#!/bin/bash

for f in ${@}; do
    convert "${f}" -trim "${f}"
done
