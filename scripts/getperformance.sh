lsb=$(/usr/bin/lsb_release -ds | sed -e 's/^"//'  -e 's/"$//')
un=$(/bin/uname -r | sed -e 's/^"//'  -e 's/"$//')
os=`echo $lsb $un`
host=$(/bin/hostname)
uptime_seconds=$(/bin/cat /proc/uptime | awk '{print $1}')
server_time=$(date)

awkCmd=`which awk`
grepCmd=`which grep`
sedCmd=`which sed`
ifconfigCmd=`which ifconfig`
trCmd=`which tr`
digCmd=`which dig`

externalIp=`$digCmd +short myip.opendns.com @resolver1.opendns.com`





diskspace=`sh diskspace.sh`
memory=`sh memory_usage.sh`
memory_details=`sh memory_usage_details.sh`
cpu_heavy_processes=`sh cpu_heavy_processes.sh`
ram_heavy_processes=`sh ram_heavy_processes.sh`
cpu_info=`sh cpu_info.sh`
logins=`sh login_log.sh`
bandwidth=`sh bandwidth.sh`
common_apps=`sh common_applications.sh`
io_stats=`sh io_stats.sh`
load_avg=`sh load_avg.sh`
netstat=`sh netstat.sh`


var cpu_free=  `expr $RANDOM % 100`

#cpu_free=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" |  awk '{print 100 - $1"%"}')

echo "{"

	echo "\"general_info\":"
	echo {\"OS\":\"$os\",\"Hostname\": \"$host\",\"Uptime\":\" $uptime_seconds\",\"server_time\":\"$server_time\" \}

	echo ","

	echo "\"cpu_free\":" \"$cpu_free\"

	echo ","


	echo "\"ip_address\":"
	echo $ifconfigCmd \
	| $grepCmd -B1 "inet addr" \
	| $awkCmd '{ if ( $1 == "inet" ) { print $2 } else if ( $2 == "Link" ) { printf "%s:" ,$1 } }' \
	| $awkCmd -v exIp="$externalIp" -F: 'BEGIN {print ""} { print "{ \"interface\": \"" $1 "\", \"ip\": \"" $3 "\" },"} END {print "{ \"interface\": \"external\", \"ip\": \""exIp"\" } "}' \
	| $trCmd -d '\r\n'

	echo ","


	echo "\"diskspace\":"
	echo $diskspace

	echo ","

	echo "\"memory\":"
	echo $memory



	echo ","

	echo "\"cpu_heavy_processes\":"
	echo $cpu_heavy_processes

	echo ","

	echo "\"ram_heavy_processes\":"
	echo $ram_heavy_processes
	echo ","

	echo "\"cpu_info\":"
	echo $cpu_info

	echo ","

	echo "\"logins\":"
	echo $logins
	echo ","

	echo "\"bandwidth\":"
	echo $bandwidth
	echo ","

	echo "\"common_apps\":"
	echo $common_apps
	echo ","

	echo "\"io_stats\":"
	echo $io_stats
	echo ","

	echo "\"load_avg\":"
	echo $load_avg
	echo ","

	echo "\"netstat\":"
	echo $netstat


echo "}"

