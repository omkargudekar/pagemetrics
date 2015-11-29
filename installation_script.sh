#!/bin/sh
setterm -term linux -back black -fore green -clear

curl https://raw.githubusercontent.com/omkargudekar/pagemetrix-info/master/credit.txt | cat

sleep 3
echo "Installation started....\n"
sleep 3

read -p "Please select the port for node-server: " nodeport
read -p "Please select the port for redi-server: " redisport



echo "Checking for git installation..."

if [ $(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No git found. Setting up wget."
  apt-get --force-yes --yes install git
fi


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

echo "Checking for unzip installation..."

if [ $(dpkg-query -W -f='${Status}' unzip 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No unzip found. Setting up unzip."
  apt-get --force-yes --yes install unzip
fi

git clone https://github.com/omkargudekar/pagemetrics.git
cd pagemetrics
npm install
npm install nodemon -g


apt-get install redis-server
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


echo "Bye Bye.. Installation complete...nJoy :) "






