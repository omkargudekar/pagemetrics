#!/bin/bash

awkCmd=`which awk`
catCmd=`which cat`
grepCmd=`which grep`
memInfoFile="/proc/meminfo"

memInfo=`$catCmd $memInfoFile | $grepCmd 'MemTotal\|MemFree\|Buffers\|Cached'`

echo $memInfo | $awkCmd '{print "{ \"total\": " ($2/1024) ", \"used\": " ( ($2-($5+$8+$11))/1024 ) ", \"free\": " (($5+$8+$11)/1024) " }"  }'
