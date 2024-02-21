#!/bin/bash
#disable bash history
set +o history

#color codes
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE="\\033[38;5;27m"
SEA="\\033[38;5;49m"
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'
dversion="v1.0"
CRTDIR=$(pwd)

function string_limit_check_mark(){
	if [[ -z "$2" ]]; then
		string="$1"
		string=${string::100}
	else
		string=$1
		string_color=$2
		string_leght=${#string}
		string_leght_color=${#string_color}
		string_diff=$((string_leght_color-string_leght))
		string=${string_color::100+string_diff}
	fi
	echo -e "${ARROW}${CYAN}$string[${CHECK_MARK}√${CYAN}]${NC}"
}

function string_limit_x_mark(){
	if [[ -z "$2" ]]; then
		string="$1"
		string=${string::50}
	else
		string=$1
		string_color=$2
		string_leght=${#string}
		string_leght_color=${#string_color}
		string_diff=$((string_leght_color-string_leght))
		string=${string_color::50+string_diff}
	fi
	echo -e "${ARROW}${CYAN}$string[${CHECK_MARK}${RED}×${CYAN}]${NC}"
}

function update_sugar_node(){
	echo -e "${CYAN}Starting to update node configuration file${NC}"
	cat << EOF >  ${CRTDIR}/.sugarchain/sugarchain.conf
server=1
rpcuser=baihe
rpcpassword=passwordbaihe
rpcallowip=127.0.0.1
addressindex=1
txindex=1
spentindex=1

addnode=172.7.16.63
addnode=211.216.3.196
addnode=195.3.222.59
addnode=75.188.243.94
EOF
	string_limit_check_mark "Node configuration file updated successfully........." "Node configuration file updated successfully${GREEN}${CYAN} ........."
}

function Start_sugar_node(){
	echo -e "${CYAN}When the sugar chain node installation program starts,You can press [CTRL+C] to cancel${NC}"
	sleep 5
	cd ~/
	
	if [[ ! -d ${CRTDIR}/.sugarchain ]]; then
		mkdir -p ${CRTDIR}/.sugarchain
	fi
	if [[ ! -f ${CRTDIR}/.sugarchain/sugarchain.conf ]]; then
		update_sugar_node
	fi
	
	if [[ ! -d ${CRTDIR}/sugarwallet-linux${system_bits} ]]; then
		git clone https://gitee.com/bailaoshijiadao/sugarwallet-linux${system_bits}.git
		chmod 755 ${CRTDIR}/sugarwallet-linux${system_bits}/bin/sugarchain-cli
		chmod 755 ${CRTDIR}/sugarwallet-linux${system_bits}/bin/sugarchaind
	fi

	if [[ -d ${CRTDIR}/sugarwallet-linux${system_bits} ]]; then
		if ! ${CRTDIR}/sugarwallet-linux${system_bits}/bin/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe getconnectioncount > /dev/null 2>&1 ; then
			#screen -ls|awk 'NR>=2&&NR<=5{print $1}'|awk '{print "screen -S "$1" -X quit"}'|sh	
			${CRTDIR}/sugarwallet-linux${system_bits}/bin/sugarchaind -daemon
			sleep 5
			if ${CRTDIR}/sugarwallet-linux${system_bits}/bin/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe getconnectioncount > /dev/null 2>&1 ; then
				string_limit_check_mark "The sugar chain node has been started. Please enter other numbers in 10 seconds to check the node status......" "The sugar chain node has been started. Please enter other numbers in 10 seconds to check the node status${GREEN}${CYAN} ......"
			fi
			sleep 5
		else
			string_limit_check_mark "The detection node has been started, there is no need to restart it again........." "The detection node has been started, there is no need to restart it again${GREEN}${CYAN} ........."
			sleep 5
		fi
	fi
}

function Stop_sugar_node(){
	cd ~/
	echo -e "${ARROW} ${YELLOW}Start closing SugarChain node ....${NC}"
	${CRTDIR}/sugarwallet-linux${system_bits}/bin/sugarchain-cli stop
	string_limit_check_mark "Successfully stopped SugarChain node......" "Successfully stopped SugarChain node${GREEN}${CYAN} ......"
	sleep 5
}

function install_step(){
	if ! figlet -v > /dev/null 2>&1; then
		echo -e "${ARROW} ${YELLOW}Installing figlet ....${NC}"
		sudo $* install -y figlet > /dev/null 2>&1
	fi


	if ! whiptail -v > /dev/null 2>&1; then
		echo -e "${ARROW} ${YELLOW}Installing whiptail ....${NC}"
		sudo $* install -y whiptail > /dev/null 2>&1
	fi

	#install JQ
	if ! jq --version > /dev/null 2>&1; then
		echo -e "${ARROW} ${YELLOW}Installing JQ ....${NC}"
		sudo $* install -y jq > /dev/null 2>&1
	fi

	if ! screen -v > /dev/null 2>&1; then
		echo -e "${ARROW} ${YELLOW}Installing screen ....${NC}"
		sudo $* install -y screen > /dev/null 2>&1
	fi
	
	if ! wget --version > /dev/null 2>&1; then
		echo -e "${ARROW} ${YELLOW}Installing wget ....${NC}"
		sudo $* install -y wget > /dev/null 2>&1
	fi
	if ! git --version > /dev/null 2>&1; then
		echo -e "${ARROW} ${YELLOW}Installing git ....${NC}"
		sudo $* install -y git > /dev/null 2>&1
	fi
	
	
	if ! ls -lh /swapfile > /dev/null 2>&1; then
		sudo fallocate -l 8G /swapfile
	fi
	
	sudo chmod 755 /swapfile
	sudo mkswap /swapfile
	sudo swapon /swapfile
	sudo swapon -s
	
	swapfile_flag=`cat /etc/fstab`
	if [[ $swapfile_flag =~ "swapfile" ]]; then
		echo -e "${ARROW} ${YELLOW}Virtual memory is automatically mounted when turned on, no need to reset....${NC}"
	else
		sed -i '$a /swapfile  none  swap  sw  0  0' /etc/fstab
		echo -e "${ARROW} ${YELLOW}Virtual memory boot auto mount setting successful....${NC}"
	fi

}

check_results=`uname -a`
if [[ $check_results =~ "Linux" ]]; then
	echo -e "${YELLOW}$check_results${NC}"
	if [[ $check_results =~ "x86_64" ]]; then
		system_bits="64"
	fi
	if [[ $check_results =~ "i686" ]]; then
		system_bits="32"
	fi
fi
# 创建crontab任务
CRON_LINE="cat /dev/null >  ${CRTDIR}/.sugarchain/debug.log"
CRON_EXISTS=$(crontab -l | grep "$CRON_LINE" | wc -l)
if [ $CRON_EXISTS -eq 0 ]
then
	crontab -l | { cat; echo "*/3600 * * * * $CRON_LINE"; } | crontab -
	string_limit_check_mark "Timed clear log task completed........." "Timed clear log task completed${GREEN}${CYAN} ........."
else
	string_limit_check_mark "Timed clearing task already exists........." "Timed clearing task already exists${GREEN}${CYAN} ........."
fi

CRON_LINE="${CRTDIR}/sugarwallet-linux${system_bits}/bin/sugarchaind -daemon"
CRON_EXISTS=$(crontab -l | grep "$CRON_LINE" | wc -l)
if [ $CRON_EXISTS -eq 0 ]
then
	crontab -l | { cat; echo "*/5 * * * * $CRON_LINE"; } | crontab -
	string_limit_check_mark "Timed start task setting completed........." "Timed start task setting completed.........${GREEN}${CYAN} ........."
else
	string_limit_check_mark "Timed start task already exists........." "Timed start task already exists${GREEN}${CYAN} ........."
fi

if ! ${CRTDIR}/sugarwallet-linux${system_bits}/bin/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe -version > /dev/null 2>&1 ; then
	#Ubuntu
	if [[ -f /etc/issue ]]; then
		system_v=$(cat /etc/issue)
		if [[ $system_v =~ "Ubuntu" ]]; then
			echo -e "${YELLOW}apt${NC}"
			sudo apt-get update
			install_step apt
		fi
	fi

	#Centos
	if [[ -f /etc/centos-release ]]; then
		echo -e "${YELLOW}yum${NC}"
		install_step yum
	else 
		if [[ -f /etc/redhat-release ]]; then
			echo -e "${YELLOW}yum${NC}"
			install_step yum
		fi
	fi

	#Centos换源
	if [[ -f /etc/centos-release ]]; then
		if ! jq --version > /dev/null 2>&1; then
			mv /etc/yum.repos.d /etc/yum.repos.d.bak
			mkdir -p /etc/yum.repos.d
			curl https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo > /etc/yum.repos.d/Centos-vault-8.5.2111.repo
			curl https://mirrors.aliyun.com/repo/epel-archive-8.repo > /etc/yum.repos.d/epel-archive-8.repo
			yum clean all && yum makecache
		fi
		install_step yum
	else 
		if [[ -f /etc/redhat-release ]]; then
			if ! jq --version > /dev/null 2>&1; then
				mv /etc/yum.repos.d /etc/yum.repos.d.bak
				mkdir -p /etc/yum.repos.d
				curl https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo > /etc/yum.repos.d/Centos-vault-8.5.2111.repo
				curl https://mirrors.aliyun.com/repo/epel-archive-8.repo > /etc/yum.repos.d/epel-archive-8.repo
				yum clean all && yum makecache
			fi
			install_step yum
		fi
	fi
fi

while :
do
	sleep 1
	echo -e "${BLUE}"
	figlet -f big "SugarChain"
	echo -e "${YELLOW}===========================================================${NC}"
	echo -e "${GREEN}Version: $dversion${NC}"
	echo -e "${GREEN}System: Linux Ubuntu Centos${NC}"
	echo -e "${GREEN}Author: bailaoshi${NC}"
	echo -e "${YELLOW}===========================================================${NC}"
	echo -e "${CYAN}1  - Start SugarChain Node[Including installation process]${NC}"
	echo -e "${CYAN}2  - Update node configuration file[Update content based on GitHub file]${NC}"
	echo -e "${CYAN}3  - View the current number of blocks${NC}"
	echo -e "${CYAN}4  - View the number of node connections${NC}"
	echo -e "${CYAN}5  - View version${NC}"
	echo -e "${CYAN}6  - Viewing the download progress of block headers${NC}"
	echo -e "${CYAN}7  - Stop SugarChain Node${NC}"
	echo -e "${YELLOW}===========================================================${NC}"
	echo -e "${YELLOW}******SugarChain creation node script******${NC}"
	echo -e "${YELLOW}Sponsorship address: sugar1qg3tyk3uzlet6spq9ewej6uacer0zrll0hk9dc0(bailaoshi)${NC}"

	read -rp "Please enter a numerical option and press Enter: "

	  case "$REPLY" in

	 1)
		sleep 2
		Start_sugar_node
	 ;;
	 2)

		sleep 2
		update_sugar_node
	 ;;
	 3) 

		sleep 2
		${CRTDIR}/sugarwallet-linux${system_bits}/bin/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe getblockcount
	 ;;
	 4) 

		sleep 2
		${CRTDIR}/sugarwallet-linux${system_bits}/bin/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe getconnectioncount
	 ;;
	 5) 

		sleep 2
		${CRTDIR}/sugarwallet-linux${system_bits}/bin/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe -version
	 ;;
	 6) 

		sleep 2
		${CRTDIR}/sugarwallet-linux${system_bits}/bin/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe getblockchaininfo | grep headers
	 ;;
	 7)
		sleep 2
		Stop_sugar_node
	 ;;

		esac

done

