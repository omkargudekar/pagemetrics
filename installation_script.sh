#!/bin/sh
setterm -term linux -back black -fore green -clear

curl https://raw.githubusercontent.com/omkargudekar/serverninja-unix-monitoring/master/credit.txt | cat &
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
  apt-get --force-yes --yes install git &
  wait
else
  echo "git is already installed..."
fi


if [ $(dpkg-query -W -f='${Status}' wget 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No wget found. Setting up wget."
  apt-get --force-yes --yes install wget &
  wait
else
  echo "wget is already installed..."
fi

echo "Checking for nodejs installation..."

if [ $(dpkg-query -W -f='${Status}' nodejs 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No nodejs found. Setting up nodejs."
  apt-get --force-yes --yes install nodejs &
  wait
  else
  echo "nodejs is already installed..."
fi

echo "Checking for npm installation..."

if [ $(dpkg-query -W -f='${Status}' nodejs npm 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No npm found. Setting up npm."
  apt-get --force-yes --yes install nodejs npm &
  wait
  else
  echo "npm is already installed..."
fi

echo "Checking for redis-server installation..."
if [ $(dpkg-query -W -f='${Status}' redis-server 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "No redis-server found. Setting up redis-server."
  apt-get --force-yes --yes install redis-server &
  wait
  else
  echo "redis-server is already installed..."
fi
wait



echo "Cleaning previous processes...if any..."
pkill -f wrapper_dashboard_998899.sh &
wait

echo "Cleaning previous installations..if any..."
rm -rf serverninja-unix-monitoring &
wait


echo "Downloading code from repository..."
git clone https://github.com/omkargudekar/serverninja-unix-monitoring.git &
wait


cd serverninja-unix-monitoring


echo "Running server-ninja agent..."
cd scripts
nohup sh runagent.sh &
echo $$ > server-ninja_agent_pid

cd ..



echo "Running redis server..."
nohup redis-server >redis.log &



echo "Installing server-ninja dashboard setup..."
npm install --silent &
wait
npm install nodemon -g --silent &
wait




nohup nodemon > dashboard.log &
echo $$ > nodeserver_pid





#publicIP= `wget http://ipinfo.io/ip -qO -`
#dashboardURL=$publicIP':5145'
#
#if curl --output /dev/null --silent --head --fail "$dashboardURL"
#then
#    echo "Dashboard is up and running on "+ $dashboardURL
#else
#    setterm -term linux -back black -fore red -clear
#
#    echo "Unable to access dashboard on " $dashboardURL "Please make sure port is open in your Cloud Hosting"
#    setterm -reset
#fi
#

echo "Bye Bye.. Installation complete...nJoy :) "






