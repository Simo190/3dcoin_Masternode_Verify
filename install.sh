#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 16.04 is the recommended opearting system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your 3dcoin   masternodes.  *"
echo "****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "!    THIS SCRIPT MUST BE RUN AS ROOT, NOT SUDO    !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

perl -i -ne 'print if ! $a{$_}++' /etc/monit/monitrc

echo "Is this your first time using this script? [y/n]"
read DOSETUP
echo ""
echo "What interface do you want to use? (4 For ipv4 or 6 for ipv6) (Automatic ipv6 optimized for vultr)"
read INTERFACE
echo ""
echo ""
echo "Do you want to install monit? (Automatically restarts node if it crashes) [y/n]"
read MONIT
IP4=$(curl -s4 api.ipify.org)
IP6=$(curl v6.ipv6-test.com/api/myip.php)

cd
if [ ! -f DynamicChain.zip ]
then
wget https://github.com/Simo190/3dcoin_Masternode_Verify/releases/download/V1/DynamicChain.zip
fi
if [ $DOSETUP = "y" ]
then
if [ $INTERFACE = "6" ]
then
  face="$(lshw -C network | grep "logical name:" | sed -e 's/logical name:/logical name: /g' | awk '{print $3}')"
  echo "iface $face inet6 static" >> /etc/network/interfaces
  echo "address $IP6" >> /etc/network/interfaces
  echo "netmask 64" >> /etc/network/interfaces
fi
  sudo apt-get update
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get update
  sudo apt-get install -y zip unzip

  
 if [ ! -f Linux.zip ]
  then
  wget https://github.com/Simo190/3dcoin_Masternode_Verify/releases/download/V1/Linux.zip
 fi
  unzip Linux.zip
  chmod +x Linux/*
  sudo mv  Linux/* /usr/local/bin
  rm -rf Linux.zip Windows Linux Mac

  sudo apt-get install -y ufw
  sudo ufw allow ssh/tcp
  sudo ufw limit ssh/tcp
  sudo ufw logging on
  echo "y" | sudo ufw enable
  sudo ufw status

  mkdir -p ~/bin
  echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
  source ~/.bashrc
  echo ""
  
  fi
## Setup Monit
if [ $MONIT = "y" ]
	then
	if [ ! -f /etc/monit/monitrc ]
then
	echo ""
    echo "Monit not found, installing it"
	apt-get install monit=1:5.16-2 -y
	wget https://github.com/Simo190/LTX-MultiMN/releases/download/Daemon/monitrc
	rm /etc/monit/monitrc
	cp -a monitrc /etc/monit/monitrc
	chmod 700 /etc/monit/monitrc
fi

fi


 ## Setup conf 
if [ $INTERFACE = "4" ]
then
echo ""
echo "How many ipv4 nodes do you already have on this server? (0 if none)"
read IP4COUNT
echo ""
echo "How many nodes do you want to create on this server? [min:1 Max:20]  followed by [ENTER]:"
read MNCOUNT
let COUNTER=0
let MNCOUNT=MNCOUNT+IP4COUNT
let COUNTER=COUNTER+IP4COUNT
while [  $COUNTER -lt $MNCOUNT ]; do
 PORT=6695
 PORTD=$((6695+$COUNTER))
 RPCPORTT=$(($PORT*10))
 RPCPORT=$(($RPCPORTT+$COUNTER))
  echo ""
  echo "Enter alias for new node"
  read ALIAS
  CONF_DIR=~/.3dcoin_$ALIAS
  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY
  mkdir ~/.3dcoin_$ALIAS
  unzip DynamicChain.zip -d ~/.3dcoin_$ALIAS
  echo '#!/bin/bash' > ~/bin/3dcoind_$ALIAS.sh
  echo "3dcoind -daemon -conf=$CONF_DIR/3dcoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/3dcoind_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/3dcoin-cli_$ALIAS.sh
  echo "3dcoin-cli -conf=$CONF_DIR/3dcoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/3dcoin-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/3dcoin-tx_$ALIAS.sh
  echo "3dcoin-tx -conf=$CONF_DIR/3dcoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/3dcoin-tx_$ALIAS.sh
  chmod 755 ~/bin/3dcoin*.sh
  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> 3dcoin.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> 3dcoin.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> 3dcoin.conf_TEMP
  echo "rpcport=$RPCPORT" >> 3dcoin.conf_TEMP
  echo "listen=1" >> 3dcoin.conf_TEMP
  echo "server=1" >> 3dcoin.conf_TEMP
  echo "daemon=1" >> 3dcoin.conf_TEMP
  echo "logtimestamps=1" >> 3dcoin.conf_TEMP
  echo "maxconnections=32" >> 3dcoin.conf_TEMP
  echo "masternode=1" >> 3dcoin.conf_TEMP
  echo "" >> 3dcoin.conf_TEMP

  echo "" >> 3dcoin.conf_TEMP
  echo "port=$PORTD" >> 3dcoin.conf_TEMP
  echo "externalip=$IP4:$PORT" >> 3dcoin.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> 3dcoin.conf_TEMP
  sudo ufw allow $PORT/tcp
  mv 3dcoin.conf_TEMP $CONF_DIR/3dcoin.conf 
  echo "Your ip is $IP4:$PORTD"
  COUNTER=$((COUNTER+1))
  
  if [ $MONIT = "y" ]
	then
	echo "alias ${ALIAS}_status=\"3dcoin-cli -datadir=/root/.3dcoin_$ALIAS masternode status\"" >> .bashrc
	echo "alias ${ALIAS}_stop=\"3dcoin-cli -datadir=/root/.3dcoin_$ALIAS stop && monit stop 3dcoind${ALIAS} && rm ~/.3dcoin_${ALIAS}/3dcoind${ALIAS}.pid\"" >> .bashrc
	echo "alias ${ALIAS}_start=\"/root/bin/3dcoind_${ALIAS}.sh && sleep 1 && mv ~/.3dcoin_${ALIAS}/3dcoind.pid ~/.3dcoin_${ALIAS}/3dcoind${ALIAS}.pid && monit start 3dcoind${ALIAS}\""  >> .bashrc
	echo "alias ${ALIAS}_config=\"nano /root/.3dcoin_${ALIAS}/3dcoin.conf\""  >> .bashrc
	echo "alias ${ALIAS}_getinfo=\"3dcoin-cli -datadir=/root/.3dcoin_$ALIAS getinfo\"" >> .bashrc
	## Config Monit
	echo "check process 3dcoind${ALIAS} with pidfile /root/.3dcoin_${ALIAS}/3dcoind${ALIAS}.pid" >> /etc/monit/monitrc
	echo "start program = \"/root/bin/3dcoind_${ALIAS}.sh\" with timeout 60 seconds" >> /etc/monit/monitrc
	echo "stop program = \"/root/bin/3dcoind_${ALIAS}.sh stop\"" >> /etc/monit/monitrc
	/root/bin/3dcoind_${ALIAS}.sh
	perl -i -ne 'print if ! $a{$_}++' /etc/monit/monitrc
	monit reload
	sleep 1
	monit
	sleep 1 
	mv ~/.3dcoin_${ALIAS}/3dcoind.pid ~/.3dcoin_${ALIAS}/3dcoind${ALIAS}.pid
	monit start 3dcoind${ALIAS}
  fi
  if [ $MONIT = "n" ]
	then
	echo "alias ${ALIAS}_status=\"3dcoin-cli -datadir=/root/.3dcoin_$ALIAS masternode status\"" >> .bashrc
	echo "alias ${ALIAS}_stop=\"3dcoin-cli -datadir=/root/.3dcoin_$ALIAS stop\"" >> .bashrc
	echo "alias ${ALIAS}_start=\"/root/bin/3dcoind_${ALIAS}.sh\""  >> .bashrc
	echo "alias ${ALIAS}_config=\"nano /root/.3dcoin_${ALIAS}/3dcoin.conf\""  >> .bashrc
	echo "alias ${ALIAS}_getinfo=\"3dcoin-cli -datadir=/root/.3dcoin_$ALIAS getinfo\"" >> .bashrc
	/root/bin/3dcoind_${ALIAS}.sh
  fi

 
    
done
fi

if [ $INTERFACE = "6" ]
then
face="$(lshw -C network | grep "logical name:" | sed -e 's/logical name:/logical name: /g' | awk '{print $3}')"
gateway1=$(/sbin/route -A inet6 | grep -w "$face")
gateway2=${gateway1:0:26}
gateway3="$(echo -e "${gateway2}" | tr -d '[:space:]')"
if [[ $gateway3 = *"128"* ]]; then
  gateway=${gateway3::-5}
fi
if [[ $gateway3 = *"64"* ]]; then
  gateway=${gateway3::-3}
fi
echo ""
echo "How many ipv6 nodes do you already have on this server? (0 if none)"
read IP6COUNT
echo ""
echo "How many nodes do you want to create on this server?"
read MNCOUNT
let MNCOUNT=MNCOUNT+1
let MNCOUNT=MNCOUNT+IP6COUNT
let COUNTER=1
let COUNTER=COUNTER+IP6COUNT

 while [  $COUNTER -lt $MNCOUNT ]; do
 echo "up /sbin/ip -6 addr add dev ens3 ${gateway}$COUNTER" >> /etc/network/interfaces
 PORT=6695 
 RPCPORTT=$(($PORT*10))
 RPCPORT=$(($RPCPORTT+$COUNTER))
    echo ""
  echo "Enter alias for new node"
  read ALIAS
  CONF_DIR=~/.3dcoin_$ALIAS
  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY
  mkdir ~/.3dcoin_$ALIAS
  unzip DynamicChain.zip -d ~/.3dcoin_$ALIAS
  echo '#!/bin/bash' > ~/bin/3dcoind_$ALIAS.sh
  echo "3dcoind -daemon -conf=$CONF_DIR/3dcoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/3dcoind_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/3dcoin-cli_$ALIAS.sh
  echo "3dcoin-cli -conf=$CONF_DIR/3dcoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/3dcoin-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/3dcoin-tx_$ALIAS.sh
  echo "3dcoin-tx -conf=$CONF_DIR/3dcoin.conf -datadir=$CONF_DIR "'$*' >> ~/bin/3dcoin-tx_$ALIAS.sh
  chmod 755 ~/bin/3dcoin*.sh
  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> 3dcoin.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> 3dcoin.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> 3dcoin.conf_TEMP
  echo "rpcport=$RPCPORT" >> 3dcoin.conf_TEMP
  echo "listen=1" >> 3dcoin.conf_TEMP
  echo "server=1" >> 3dcoin.conf_TEMP
  echo "daemon=1" >> 3dcoin.conf_TEMP
  echo "logtimestamps=1" >> 3dcoin.conf_TEMP
  echo "maxconnections=256" >> 3dcoin.conf_TEMP
  echo "masternode=1" >> 3dcoin.conf_TEMP
  echo "" >> 3dcoin.conf_TEMP

  echo "" >> 3dcoin.conf_TEMP
  echo "bind=[${gateway}$COUNTER]" >> 3dcoin.conf_TEMP
  echo "port=$PORT" >> 3dcoin.conf_TEMP
  echo "externalip=[${gateway}$COUNTER]:$PORT" >> 3dcoin.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> 3dcoin.conf_TEMP
  sudo ufw allow $PORT/tcp
  mv 3dcoin.conf_TEMP $CONF_DIR/3dcoin.conf
  systemctl restart networking.service
  sleep 1
  mv ~/.3dcoin_${ALIAS}/3dcoind.pid ~/.3dcoin_${ALIAS}/3dcoind${ALIAS}.pid
  echo "Your ip is [${gateway}$COUNTER]"
  COUNTER=$((COUNTER+1))
  
  if [ $MONIT = "y" ]
	then
	echo "alias ${ALIAS}_status=\"3dcoin-cli -datadir=/root/.3dcoin_$ALIAS masternode status\"" >> .bashrc
	echo "alias ${ALIAS}_stop=\"3dcoin-cli -datadir=/root/.3dcoin_$ALIAS stop && monit stop 3dcoind${ALIAS} && rm ~/.3dcoin_${ALIAS}/3dcoind${ALIAS}.pid\"" >> .bashrc
	echo "alias ${ALIAS}_start=\"/root/bin/3dcoind_${ALIAS}.sh && sleep 1 && mv ~/.3dcoin_${ALIAS}/3dcoind.pid ~/.3dcoin_${ALIAS}/3dcoind${ALIAS}.pid && monit start 3dcoind${ALIAS}\""  >> .bashrc
	echo "alias ${ALIAS}_config=\"nano /root/.3dcoin_${ALIAS}/3dcoin.conf\""  >> .bashrc
	echo "alias ${ALIAS}_getinfo=\"3dcoin-cli -datadir=/root/.3dcoin_$ALIAS getinfo\"" >> .bashrc
	## Config Monit
	echo "check process 3dcoind${ALIAS} with pidfile /root/.3dcoin_${ALIAS}/3dcoind${ALIAS}.pid" >> /etc/monit/monitrc
	echo "start program = \"/root/bin/3dcoind_${ALIAS}.sh\" with timeout 60 seconds" >> /etc/monit/monitrc
	echo "stop program = \"/root/bin/3dcoind_${ALIAS}.sh stop\"" >> /etc/monit/monitrc
	/root/bin/3dcoind_${ALIAS}.sh
	perl -i -ne 'print if ! $a{$_}++' /etc/monit/monitrc
	monit reload
	sleep 1
	monit
	sleep 1 
	mv ~/.3dcoin_${ALIAS}/3dcoind.pid ~/.3dcoin_${ALIAS}/3dcoind${ALIAS}.pid
	monit start 3dcoind${ALIAS}
  fi
  if [ $MONIT = "n" ]
	then
	echo "alias ${ALIAS}_status=\"3dcoin-cli -datadir=/root/.3dcoin_$ALIAS masternode status\"" >> .bashrc
	echo "alias ${ALIAS}_stop=\"3dcoin-cli -datadir=/root/.3dcoin_$ALIAS stop\"" >> .bashrc
	echo "alias ${ALIAS}_start=\"/root/bin/3dcoind_${ALIAS}.sh\""  >> .bashrc
	echo "alias ${ALIAS}_config=\"nano /root/.3dcoin_${ALIAS}/3dcoin.conf\""  >> .bashrc
	echo "alias ${ALIAS}_getinfo=\"3dcoin-cli -datadir=/root/.3dcoin_$ALIAS getinfo\"" >> .bashrc
	/root/bin/3dcoind_${ALIAS}.sh
	fi
  done


## Final echos
echo ""
echo "Commands:"
echo "ALIAS_start"
echo "ALIAS_status"
echo "ALIAS_stop"
echo "ALIAS_config"
echo "ALIAS_getinfo"
perl -i -ne 'print if ! $a{$_}++' /etc/monit/monitrc
exec bash
