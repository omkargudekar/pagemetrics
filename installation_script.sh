#!/bin/sh
setterm -term linux -back black -fore green -clear

curl https://raw.githubusercontent.com/omkargudekar/pagemetrix-info/master/credit.txt | cat
wait
sleep 3
echo "Installation started....\n"
wait
sleep 3

echo -n "Please select the port for node-server: "
read nodeport


echo -n "Please select the port for redis-server: "
read -p redisport
wait



echo "Checking for git installation..."
wait
if [ $(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No git found. Setting up wget."
  apt-get --force-yes --yes install git
fi
wait

if [ $(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No nodejs found. Setting up wget."
  apt-get --force-yes --yes install wget
fi
wait
echo "Checking for nodejs installation..."

if [ $(dpkg-query -W -f='${Status}' nodejs 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No nodejs found. Setting up nodejs."
  apt-get --force-yes --yes install nodejs
fi
wait
echo "Checking for npm installation..."

if [ $(dpkg-query -W -f='${Status}' nodejs npm 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No nodejs found. Setting up npm."
  apt-get --force-yes --yes install nodejs npm
fi
wait
echo "Checking for redis-server installation..."
if [ $(dpkg-query -W -f='${Status}' redis-server 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No nodejs found. Setting up redis-server."
  apt-get --force-yes --yes install redis-server
fi
wait

echo "Checking for unzip installation..."

if [ $(dpkg-query -W -f='${Status}' unzip 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No unzip found. Setting up unzip."
  apt-get --force-yes --yes install unzip
fi
wait

git clone https://github.com/omkargudekar/pagemetrics.git
wait
cd pagemetrics
npm install
wait
npm install nodemon -g
wait

apt-get install redis-server
wait

pkill -f wrapper_dashboard_998899.sh

rm -rf pagemetrics
wait

nohup redis-server --port $redisport >redis.log &
echo $$ > redit_agent_pid
nohup nodemon --port $nodeport > dashboard.log &
echo $$ > nodeserver_pid
cd scripts
nohup sh runagent.sh &
echo $$ > pagemetrics_agent_pid


dashboardURL="http://www.google.com"

if curl --output /dev/null --silent --head --fail "$dashboardURL"
then
    echo "This URL Exist"
else
    echo "This URL Not Exist"
fi
wait

echo "Bye Bye.. Installation complete...nJoy :) "






