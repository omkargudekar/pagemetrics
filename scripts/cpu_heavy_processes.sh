#!/bin/bash

result=$(/bin/ps axo pid,user,pcpu,rss,vsz,comm --sort -pcpu,-rss,-vsz \
			| head -n 15 \
			| /usr/bin/awk 'BEGIN{OFS=":"} NR>1 {print "{ \"pid\": " $1 \
							", \"name\": \"" $2 "\"" \
							", \"z\": " $3 \
							", \"y\": " $4 \
							", \"x\": " $5 \
							", \"cmd\": \"" $6 "\"" "},"\
						}')

echo "[" ${result%?} "]"