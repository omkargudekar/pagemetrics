#!/bin/sh
setterm -term linux -back black -fore green -clear
$nodeport=52300

curl https://raw.githubusercontent.com/omkargudekar/pagemetrix-info/master/credit.txt | cat
wait
sleep 5
echo "Installation started...."
wait
sleep 3


echo "Checking for git installation..."
wait
if [ $(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No git found. Setting up git."
  apt-get --force-yes --yes install git
else
  echo "git is already installed..."
fi
wait

if [ $(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No wget found. Setting up wget."
  apt-get --force-yes --yes install wget
else
  echo "wget is already installed..."
fi
wait

echo "Checking for nodejs installation..."

if [ $(dpkg-query -W -f='${Status}' nodejs 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No nodejs found. Setting up nodejs."
  apt-get --force-yes --yes install nodejs
  else
  echo "nodejs is already installed..."
fi
wait
echo "Checking for npm installation..."

if [ $(dpkg-query -W -f='${Status}' nodejs npm 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No npm found. Setting up npm."
  apt-get --force-yes --yes install nodejs npm
  else
  echo "npm is already installed..."
fi
wait
echo "Checking for redis-server installation..."
if [ $(dpkg-query -W -f='${Status}' redis-server 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No redis-server found. Setting up redis-server."
  apt-get --force-yes --yes install redis-server
  else
  echo "redis-server is already installed..."
fi
wait


echo "Downloading code from repository..."
git clone https://github.com/omkargudekar/pagemetrics.git
wait

echo "Cleaning previous processes...if any..."
pkill -f wrapper_dashboard_998899.sh
wait
rm -rf pagemetrics
wait



echo "Cleaning previous installations..if any..."
cd pagemetrics
npm install
wait
npm install nodemon -g
wait


echo "Running pagemetrics agent..."
cd scripts
nohup sh runagent.sh &
echo $$ > pagemetrics_agent_pid


echo "Checking redis server..."

redisReply= `redis-cli PING`

if [ $redisReply -ne "PONG" ];
then
  echo "Redis server is down. Starting redis-server"
  echo -n "Please select the port for redis-server: "
  read -p redisport
  wait
  nohup redis-server >redis.log &
  echo $$ > redit_agent_pid
else



echo "Starting node server..."


nohup nodemon --port $nodeport > dashboard.log &
echo $$ > nodeserver_pid



  echo "Redis-Server is already running..."
fi




publicIP= `wget http://ipinfo.io/ip -qO -`
dashboardURL=publicIP':'$nodeport



if curl --output /dev/null --silent --head --fail "$dashboardURL"
then
    echo "Dashboard is up and running on "+ $dashboardURL
else
    setterm -term linux -back black -fore red -clear

    echo "Unable to access dashboard on " $dashboardURL "Please make sure port is open in your Cloud Hosting"
fi
wait

setterm -reset

echo "Bye Bye.. Installation complete...nJoy :) "






