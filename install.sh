#!/bin/bash
####################################################
# TELOSCOIN MASTERNODE INSTALLER WITH TOR          #
#                                                  #
#  https://github.com/taperj/teloscoin-tor         #
#                                                  #
#  V. 0.0.2                                        #
#                                                  #
#  By: taperj                                      #
#                                                  #
####################################################
RED='\033[0;31m'
NC='\033[0m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
WHITE='\033[1;37m'
#
#
#Root user check
if [ "$EUID" -ne 0 ]
  then printf "${YELLOW}Please run as root or with sudo. ${RED}Exiting.${NC}\n"
  exit
fi
#
#
#printf "${YELLOW}${NC}\n"
printf "${RED}***************************************************************************${NC}\n"
printf "${RED}****************${YELLOW}WELCOME TO THE TELOSCOIN MASTERNODE INSTALLER${RED}****************${NC}\n"
printf "${YELLOW}******THIS SCRIPT WILL INSTALL A DOCKER CONTAINER WITH TRANSCENDENCED AND TOR*****${NC}\n"
printf "${RED}***************************************************************************${NC}\n"
#
#
#Get install info:
#
printf "${WHITE}Enter the masternode privkey and hit enter:${NC}\n"
read MASTERNODEPRIVKEY
#
#
#Get masternode's public ip
#
printf "${WHITE}Detecting Public IP..."
#
#Check for cURL
if ! [ -x "$(command -v curl)" ]; then
        printf "${RED}cURL is not detected or not executable.${GREEN} Installing cURL.${NC}\n"
        apt-get -y install curl
fi
#
PUBLICIP=$(curl -s ifconfig.me)
printf "${GREEN}Public IP detected is: $PUBLICIP${NC}\n"
#
printf "${WHITE}Enter the ip you would like to use for the masternode and hit enter:${NC}\n"
read MASTERNODEADDR
#
#
#Port specification
#make sure not to conflict with tor on 9050 and 9051
#
printf "${WHITE}Enter the port number you'd like transcendenced to listen on, default Port 8051 will be used if no port specified.${NC}\n"
read PORTNUMBER

if [ "$PORTNUMBER" != "" ]
  then
        if [ "$PORTNUMBER" = "9050" ] || [ "$PORTNUMBER" = "9051" ]
                then
                        printf "${RED}Port $PORTNUMBER specified in user input. $PORTNUMBER is reserved for Tor. Exiting.${NC}\n"
                        printf "${RED}PLEASE RE-RUN THE SCRIPT SELECTING A DIFFERENT PORT.${NC}\n"
                        exit
        fi
          printf "${YELLOW}Port $PORTNUMBER specified in user input. Port $PORTNUMBER will be configured.${NC}\n"
  else
          printf "${YELLOW}No port number specified. Default Port 8051 will be used.${NC}\n"
          PORTNUMBER=8051
fi

#
#
#RPC
#
printf "${WHITE}Enter a username for RPC:${NC}\n"
read RPCUSER
printf "${WHITE}Enter a password for RPC:${NC}\n"
read RPCPASSWORD
printf "${WHITE}SANITY CHECK...${NC}\n"
#
#
#Sanity check
#
#####
#
#Check for docker
#
if ! [ -x "$(command -v docker)" ]; then
	printf "${RED}docker is not detected or not executable.${GREEN} Installing docker.${NC}\n"
	apt-get -y install docker docker.io
fi

if [ -x "$(command -v docker)" ]; then
        printf "${YELLOW}docker detected and executable.${GREEN} Continuing.${NC}\n"
fi

#
#
#Check for files and dirs needed
for file in transcendence.conf Dockerfile services/transcendenced/run services/transcendenced/finish services/tor/run services/tor/finish
do
if [ ! -f $file ]; then
	printf "${RED}SANITY CHECK FAILED: $file not found in the current directory, exiting!${NC}\n"
	exit
fi
done
#
#
##
for dir in services services/transcendenced services/tor 
do
if [ ! -d $dir ]; then
	printf "${RED}SANITY CHECK FAILED: $dir directory not found, exiting!${NC}\n"
	exit
	fi
done
##
printf "${GREEN}SANITY CHECK PASSED!${NC}\n"
printf "${YELLOW}BEGINNING INSTALL...${NC}\n"
#
#
#
#
#Edit transcendence.conf:
#
printf "${YELLOW}Editing transcendence.conf...${NC}\n"
sed -i "s/masternodeprivkey=/masternodeprivkey=$MASTERNODEPRIVKEY/g" transcendence.conf
sed -i "s/masternodeaddr=/masternodeaddr=$MASTERNODEADDR/g" transcendence.conf
sed -i "s/rpcuser=/rpcuser=$RPCUSER/g" transcendence.conf
sed -i "s/rpcpassword=/rpcpassword=$RPCPASSWORD/g" transcendence.conf
sed -i "s/port=/port=$PORTNUMBER/g" transcendence.conf
#
#
#Edit Dockerfile
printf "${YELLOW}Editing Dockerfile...${NC}\n"
sed -i "s/HiddenServicePort 8051 127.0.0.1:8051/HiddenServicePort $PORTNUMBER 127.0.0.1:$PORTNUMBER/g" Dockerfile
#
#
#Build image
#
printf "${YELLOW}Building docker image telos-tor...${NC}\n"
docker build -t telos-tor-$PORTNUMBER .
#
#Create container
#
printf "${YELLOW}Creating container telos-tor...${NC}\n"
docker create --name telos-tor-$PORTNUMBER --restart=always -p $PORTNUMBER:$PORTNUMBER telos-tor-$PORTNUMBER:latest
#
#
#Start container
#
printf "${YELLOW}Starting container telos-tor...${NC}\n"
docker container start telos-tor-$PORTNUMBER
sleep 4
docker ps
printf "${GREEN}INSTALLATION COMPLETE.${NC}\n"
printf "${YELLOW}ONCE SYNCED YOU CAN GET THE TOR(onion) ADDRESS TO ADD TO YOUR COLD WALLET masternode.conf as server address with:${NC}\n"
printf "${WHITE}$ sudo docker container exec telos-tor-$PORTNUMBER grep AddLocal /home/transcendence/.transcendence/debug.log${NC}\n"
printf "${YELLOW}THE ABOVE COMMAND SHOULD OUTPUT SOMETHING LIKE THIS EXAMPLE OUTPUT:${NC}\n"
printf "${WHITE}2019-11-24 02:33:16 AddLocal(zsddfken27kdsdx.onion:$PORTNUMBER,4)${NC}\n"
printf "${YELLOW}in this example you would add ${GREEN}zsddfken27kdsdx.onion:$PORTNUMBER${YELLOW} to your cold wallet masternode.conf as ip addr for this alias. Yours will be different than the example.${NC}\n"
printf "${RED}IMPORTANT: IF YOU ARE RUNNING A FIREWALL MAKE SURE TO ALLOW PORT $PORTNUMBER/TCP FOR transcendenced${NC}\n"
printf "${YELLOW}Tips for the developer:${NC}\n"
printf "${YELLOW}BTC: 3HLx5AMe9S5SWzVqLwAib3oyGZm5nAAWKe${NC}\n"
printf "${YELLOW}TELOS: GPbuPVWKMKBYghszKi8N2iBCJgufmu3Li2${NC}\n"
printf "${YELLOW}HAVE FUN ANONYMOUS TELOSCOIN MASTERNODING!${NC}\n"
