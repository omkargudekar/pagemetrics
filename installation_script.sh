#!/bin/sh
setterm -term linux -back black -fore green -clear

cat credit.txt
echo "################################################################"
echo "Installation"
echo "################################################################"

read -p "Please select the port where you want to run the dashboard : " nodeport
read -p "Please select the p: " redisport



echo "Checking for wget installation..."

if [ $(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No nodejs found. Setting up wget."
  apt-get --force-yes --yes install wget
fi

echo "Checking for nodejs installation..."

if [ $(dpkg-query -W -f='${Status}' nodejs 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No nodejs found. Setting up nodejs."
  apt-get --force-yes --yes install nodejs
fi

echo "Checking for npm installation..."

if [ $(dpkg-query -W -f='${Status}' nodejs npm 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No nodejs found. Setting up npm."
  apt-get --force-yes --yes install nodejs npm
fi

echo "Checking for redis-server installation..."

if [ $(dpkg-query -W -f='${Status}' redis-server 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No nodejs found. Setting up redis-server."
  apt-get --force-yes --yes install redis-server
fi



wget https://github.com/omkargudekar/pagemetrix-info/blob/master/pagemetrics-dashboard.tar.bz2?raw=true
tar -jxvf pagemetrix-dashboard.tar.bz2
cd pagemetrix-dashboard
npm install
npm install nodemon -g


apt-get install redis-server
nohup redis-server --port $redisport &
echo $$ > redit_agent_pid
nohup nodemon --port $nodeport &
echo $$ > nodeserver_pid
cd scripts
sh runagent.sh
echo $$ > pagemetrics_agent_pid

echo "Bye Bye.. Installation complete...nJoy :) "






