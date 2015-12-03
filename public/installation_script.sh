#!/bin/sh
setterm -term linux -back black -fore green -clear

curl https://raw.githubusercontent.com/omkargudekar/serverninja-unix-monitoring/master/credit.txt | cat &
wait
sleep 5
echo "Installation started...."
wait
sleep 3

echo "updating apt-get list..."

apt-get update --force-yes --yes &
wait

echo "Checking git.."

apt-get --force-yes --yes install git &
wait

echo "Checking wget.."

apt-get --force-yes --yes install wget &
wait


echo "Checking for nodejs..."
apt-get --force-yes --yes install nodejs &
wait

echo "creating node alias"

ln -s `which nodejs` /usr/bin/node


echo "Checking for npm..."
apt-get --force-yes --yes install npm &
wait


echo "Checking for redis-server ..."
apt-get --force-yes --yes install redis-server &
wait



echo "Cleaning previous processes...if any..."
pkill -f wrapper_dashboard_998899.sh


echo "Cleaning previous installations..if any..."
rm -rf serverninja-unix-monitoring &
wait


echo "Downloading code from repository..."
git clone https://github.com/omkargudekar/serverninja-unix-monitoring.git &
wait

echo "Running redis server..."
nohup redis-server >redis.log &




cd serverninja-unix-monitoring

echo "Running server-ninja agent..."
cd scripts
nohup sh runagent.sh &
echo $$ > server-ninja_agent_pid

cd ..





echo "Installing server-ninja dashboard setup... DO NOT EXIT"
npm install --silent &
wait
npm install nodemon -g --silent &
wait




nohup nodemon > dashboard.log &
echo $$ > nodeserver_pid





echo "Press any key to continue...nJoy :) "






