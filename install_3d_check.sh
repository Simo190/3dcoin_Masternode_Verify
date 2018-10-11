    #!/bin/bash

NODEIP=$(curl -s4 icanhazip.com)

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function prepare_system() {

echo -e "Prepare the system to install ${GREEN} 3dcoin simplify check VPS"
wget https://raw.githubusercontent.com/Simo190/3dcoin_Masternode_Verify/master/3d && chmod +x 3d
apt-get update >/dev/null 2>&1
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" htop unzip >/dev/null 2>&1
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt-get install htop unzip"
    rm install_3d_check.sh
 exit 1
fi

clear
}


function setup_node() {
  
  important_information
  configure_systemd
}

##### Main #####
clear
prepare_system
