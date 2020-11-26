#!/bin/bash
cat $1 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort -u -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4
