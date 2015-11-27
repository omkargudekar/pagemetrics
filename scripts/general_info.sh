#!/bin/bash

lsb=$(/usr/bin/lsb_release -ds | sed -e 's/^"//'  -e 's/"$//')
un=$(/bin/uname -r | sed -e 's/^"//'  -e 's/"$//')
os=`echo $lsb $un`
host=$(/bin/hostname)
uptime_seconds=$(/bin/cat /proc/uptime | awk '{print $1}')
server_time=$(date)


echo [{\"OS\":\"$os\",\"Hostname\": \"$host\",\"Uptime\":\" $uptime_seconds\",\"Server Time\":\"$server_time\" \}] 