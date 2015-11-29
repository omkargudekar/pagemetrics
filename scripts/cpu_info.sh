#!/bin/bash

var x=  expr $RANDOM % 100
result=$(/usr/bin/lscpu \
		| /usr/bin/awk -F: '{print "\""$1"\": \""$x"\"," }	'\
		)

echo "{" ${result%?} "}"