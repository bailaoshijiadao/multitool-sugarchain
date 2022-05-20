#!/bin/bash

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
		string=${string::70}
	else
		string=$1
		string_color=$2
		string_leght=${#string}
		string_leght_color=${#string_color}
		string_diff=$((string_leght_color-string_leght))
		string=${string_color::70+string_diff}
	fi
	echo -e "${ARROW} ${CYAN}$string[${CHECK_MARK}√${CYAN}]${NC}"
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
	echo -e "${ARROW} ${CYAN}$string[${CHECK_MARK}${RED}×${CYAN}]${NC}"
}


function Modify_sugarchain_miner_conf(){

	if [[ -f ${CRTDIR}/sugarchain_miner_conf.json ]]; then
		read_config
	fi
	
	if [[ -f ${CRTDIR}/pool-list.json ]]; then
		echo
	else
		curl -O https://raw.githubusercontent.com/bailaoshijiadao/multitool-sugarchain/master/pool-list.json
	fi
	
	if whiptail --yesno "Would you like use old sugar address?" 8 40; then
		string_limit_check_mark "sugar address $sugar_address................................." "sugar address ${GREEN}$sugar_address${CYAN}................................."
		sleep 2
	else
		while true 
		do
			sugar_address=$(whiptail --inputbox "Please enter your sugar address" 8 40 3>&1 1>&2 2>&3)
			if [[ "$sugar_address" == sugar* ]]; then
				string_limit_check_mark "sugar address $sugar_address  format is valid................................." "sugar address ${GREEN}$sugar_address${CYAN}  format is valid................................."
				sleep 1
				break
			else
				string_limit_x_mark "Sugar address $sugar_address is not valid ..............................."
				sleep 5			
			fi
		done
	fi
	
	pool=$(cat ${CRTDIR}/pool-list.json)
	#pool=$(curl -O https://raw.githubusercontent.com/bailaoshijiadao/multitool-sugarchain/master/pool-list.json)
	
	if whiptail --yesno "Would you like use old pool:\n$pool?" 8 40; then
		string_limit_check_mark "Pool address $pool_address................................." "Pool address ${GREEN}$pool_address${CYAN}................................."
		sleep 2
	else
		while true 
		do
			pool_address=$(whiptail --inputbox "Please enter your Pool address or IP\nChoose from the following mining pools\n$pool" 16 40 3>&1 1>&2 2>&3)
			if [[ "$pool_address" == *.*.*:* || "$pool_address" == *.*.*.*:* ]]; then
				string_limit_check_mark "Pool address $pool_address format is valid................................." "Pool address ${GREEN}$pool_address${CYAN} format is valid................................."
				sleep 1
				break
			else
				string_limit_x_mark "Pool address $pool_address1 is not valid ..............................."
				sleep 5
			fi
		done
	fi
	
	if whiptail --yesno "Would you like use old miner cores:\n$miner_cores cores?" 8 40; then
		string_limit_check_mark "Miner cores $miner_cores................................." "Miner cores ${GREEN}$miner_cores${CYAN}................................."
		sleep 2
	else
		while true 
		do
			miner_cores=$(whiptail --inputbox "Please enter your miner cores(optional), defaults to 100% CPU" 8 40 3>&1 1>&2 2>&3)
			if [[ "$miner_cores" =~ ^[0-9]*$ ||  "$miner_cores" == "" ]]; then
				string_limit_check_mark "Miner cores $miner_cores format is valid................................." "Miner cores ${GREEN}$miner_cores${CYAN} format is valid................................."
				sleep 1
				break
			else
				string_limit_x_mark "Miner cores $miner_cores is not valid ..............................."
				sleep 5
			fi
		done
	fi
	
	if whiptail --yesno "Would you like use old machinary code:\n$machinary_code?" 8 40; then
		string_limit_check_mark "Machinary code $machinary_code................................." "Machinary code ${GREEN}$machinary_code${CYAN}................................."
		sleep 2
	else
		while true 
		do
			machinary_code=$(whiptail --inputbox "Please enter your machinary code(optional)" 8 40 3>&1 1>&2 2>&3)
			if [[ "$machinary_code" == "" ||  "$miner_cores" == * ]]; then
				string_limit_check_mark "Machinary code $machinary_code format is valid................................." "Machinary code ${GREEN}$machinary_code${CYAN} format is valid................................."
				sleep 1
				break
			fi
		done
	fi
	
	cat << EOF >  ${CRTDIR}/sugarchain_miner_conf.json
{
	"sugar_address":"${sugar_address}",
	"pool_address":"${pool_address}",
	"miner_cores":"${miner_cores}",
	"machinary_code":"${machinary_code}"
}
EOF

string_limit_check_mark "Modify mining configuration succeeded................................." "Modify mining configuration succeeded................................."
}


function creat_sugarchain_miner_conf(){

	if [[ -f ${CRTDIR}/pool-list.json ]]; then
		echo
	else
		curl -O https://raw.githubusercontent.com/bailaoshijiadao/multitool-sugarchain/master/pool-list.json
	fi
	
	while true 
	do
		sugar_address=$(whiptail --inputbox "Please enter your sugar address" 8 40 3>&1 1>&2 2>&3)
		if [[ "$sugar_address" == sugar* ]]; then
			string_limit_check_mark "sugar address $sugar_address  format is valid................................." "sugar address ${GREEN}$sugar_address${CYAN}  format is valid................................."
			sleep 1
			break
		else
			string_limit_x_mark "Sugar address $sugar_address is not valid ..............................."
			sleep 5			
		fi
	done
	
	pool=$(cat ${CRTDIR}/pool-list.json)
	#pool=$(curl -O https://raw.githubusercontent.com/bailaoshijiadao/multitool-sugarchain/master/pool-list.json)
	
	while true 
	do
		pool_address=$(whiptail --inputbox "Please enter your Pool address or IP\nChoose from the following mining pools\n$pool" 16 40 3>&1 1>&2 2>&3)
		if [[ "$pool_address" == *.*.*:* || "$pool_address" == *.*.*.*:* ]]; then
			string_limit_check_mark "Pool address $pool_address format is valid................................." "Pool address ${GREEN}$pool_address${CYAN} format is valid................................."
			sleep 1
			break
		else
			string_limit_x_mark "Pool address $pool_address1 is not valid ..............................."
			sleep 5
		fi
	done
	
	while true 
	do
		miner_cores=$(whiptail --inputbox "Please enter your miner cores(optional), defaults to 100% CPU" 8 40 3>&1 1>&2 2>&3)
		if [[ "$miner_cores" =~ ^[0-9]*$ ||  "$miner_cores" == "" ]]; then
			string_limit_check_mark "Miner cores $miner_cores format is valid................................." "Miner cores ${GREEN}$miner_cores${CYAN} format is valid................................."
			sleep 1
			break
		else
			string_limit_x_mark "Miner cores $miner_cores is not valid ..............................."
			sleep 5
		fi
	done
	
	while true 
	do
		machinary_code=$(whiptail --inputbox "Please enter your machinary code(optional)" 8 40 3>&1 1>&2 2>&3)
		if [[ "$machinary_code" == "" ||  "$miner_cores" == * ]]; then
			string_limit_check_mark "Machinary code $machinary_code format is valid................................." "Machinary code ${GREEN}$machinary_code${CYAN} format is valid................................."
			sleep 1
			break
		fi
	done
	
	cat << EOF >  ${CRTDIR}/sugarchain_miner_conf.json
{
	"sugar_address":"${sugar_address}",
	"pool_address":"${pool_address}",
	"miner_cores":"${miner_cores}",
	"machinary_code":"${machinary_code}"
}
EOF

string_limit_check_mark "Creat mining configuration succeeded................................." "Creat mining configuration succeeded................................."
}


function read_config(){
	sugar_address=$(cat ${CRTDIR}/sugarchain_miner_conf.json | jq -r '.sugar_address')
	string_limit_check_mark "sugar address $sugar_address ................................." "sugar address ${GREEN}$sugar_address${CYAN} ................................."
	pool_address=$(cat ${CRTDIR}/sugarchain_miner_conf.json | jq -r '.pool_address')
	string_limit_check_mark "pool address $pool_address ................................." "pool address ${GREEN}$pool_address${CYAN} ................................."
	miner_cores=$(cat ${CRTDIR}/sugarchain_miner_conf.json | jq -r '.miner_cores')
	string_limit_check_mark "miner cores $miner_cores ................................." "miner cores ${GREEN}$miner_cores${CYAN} ................................."
	machinary_code=$(cat ${CRTDIR}/sugarchain_miner_conf.json | jq -r '.machinary_code')
	string_limit_check_mark "machinary code $machinary_code ................................." "machinary code ${GREEN}$machinary_code${CYAN} ................................."
}


function Start_sugar_miner(){
	echo -e "${CYAN}Sugarchain cpuminer setup starting,you can press [CTRL+C] to cancel.${NC}"
	sleep 5
	cd ~/
	
	if [[ -f ${CRTDIR}/sugarchain_miner_conf.json ]]; then
		read_config
	else
		creat_sugarchain_miner_conf
	fi
	
	if [[! -f ${CRTDIR}/sugarchain-aarch64 ]]; then
		curl -O https://raw.githubusercontent.com/bailaoshijiadao/sugarchain-aarch64/main/sugarchain-aarch64
		chmod 777 sugarchain-aarch64
	fi
	
	if [[ "$miner_cores" == "" ]]; then
		./sugarchain-aarch64 -o stratum+tcp://$pool_address -u $sugar_address
	else
		./sugarchain-aarch64 -o stratum+tcp://$pool_address -u $sugar_address.$machinary_code
	fi

	string_limit_check_mark "Start sugar miner succeeded................................." "Start sugar miner succeeded${GREEN}${CYAN} ................................."
	echo -e "${YELLOW}******sugarmaker 2.5.0-sugar4 by Kanon******${NC}"
	echo -e "${YELLOW}Multi-threaded CPU miner for Sugarchain and other Yespower variants${NC}"
	echo -e "${YELLOW}SUGAR donation: sugar1qg3tyk3uzlet6spq9ewej6uacer0zrll0hk9dc0(bailaoshi)${NC}"
}


if ! figlet -v > /dev/null 2>&1; then
	echo -e "${ARROW} ${YELLOW}Installing figlet....${NC}"
	apt install -y figlet > /dev/null 2>&1
fi


if ! whiptail -v > /dev/null 2>&1; then
	echo -e "${ARROW} ${YELLOW}Installing whiptail....${NC}"
	apt install whiptail -y > /dev/null 2>&1
fi

#install JQ
if ! jq --version > /dev/null 2>&1; then
	echo -e "${ARROW} ${YELLOW}Installing JQ....${NC}"
	apt install jq -y > /dev/null 2>&1
fi

sleep 1
echo -e "${BLUE}"
figlet -f big "SugarChain"
echo -e "${YELLOW}================================================================${NC}"
echo -e "${GREEN}Version: $dversion${NC}"
echo -e "${GREEN}OS: Android > 7.0${NC}"
echo -e "${GREEN}Author:bailaoshi${NC}"
echo -e "${GREEN}Special thanks to Kanon${NC}"
echo -e "${YELLOW}================================================================${NC}"
echo -e "${CYAN}1  - Start sugar miner${NC}"
echo -e "${CYAN}2  - Modify mining configuration${NC}"
echo -e "${YELLOW}================================================================${NC}"
echo -e "${YELLOW}******sugarmaker 2.5.0-sugar4 by Kanon******${NC}"
echo -e "${YELLOW}Multi-threaded CPU miner for Sugarchain and other Yespower variants${NC}"
echo -e "${YELLOW}SUGAR donation: sugar1qg3tyk3uzlet6spq9ewej6uacer0zrll0hk9dc0(bailaoshi)${NC}"

read -rp "Pick an option and hit ENTER: "

  case "$REPLY" in

 1)
    sleep 1
    Start_sugar_miner
 ;;
 2) 

    sleep 1
    Modify_sugarchain_miner_conf
 ;;

    esac
