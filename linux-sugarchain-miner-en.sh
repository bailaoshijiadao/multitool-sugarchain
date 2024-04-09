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
		string_limit_check_mark "Sugar address $sugar_address................................." "Sugar address ${GREEN}$sugar_address${CYAN}................................."
		sleep 2
	else
		while true 
		do
			sugar_address=$(whiptail --inputbox "Please enter your sugar address" 8 40 3>&1 1>&2 2>&3)
			if [[ "$sugar_address" == sugar* ]]; then
				string_limit_check_mark "Sugar address $sugar_address  format is valid................................." "Sugar address ${GREEN}$sugar_address${CYAN}  format is valid................................."
				sleep 1
				break
			else
				string_limit_x_mark "Sugar address $sugar_address is not valid..............................."
				sleep 5			
			fi
		done
	fi
	
	pool=$(cat ${CRTDIR}/pool-list.json)
	#pool=$(curl -O https://raw.githubusercontent.com/bailaoshijiadao/multitool-sugarchain/master/pool-list.json)
	
	if whiptail --yesno "Would you like use old pool?" 8 40; then
		string_limit_check_mark "Pool address $pool_address................................." "Pool address ${GREEN}$pool_address${CYAN}................................."
		sleep 2
	else
		while true 
		do
			pool_address=$(whiptail --inputbox "Please enter your Pool address or IP\nChoose from the following mining pools\n$pool" 16 40 39.98.39.1:6678 3>&1 1>&2 2>&3)
			if [[ "$pool_address" == *.*.*:* || "$pool_address" == *.*.*.*:* ]]; then
				string_limit_check_mark "Pool address $pool_address format is valid................................." "Pool address ${GREEN}$pool_address${CYAN} format is valid................................."
				sleep 1
				break
			else
				string_limit_x_mark "Pool address $pool_address1 is not valid..............................."
				sleep 5
			fi
		done
	fi
	
	if whiptail --yesno "Would you like use old miner cores?" 8 40; then
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
				string_limit_x_mark "Miner cores $miner_cores is not valid..............................."
				sleep 5
			fi
		done
	fi
	
	if whiptail --yesno "Would you like use old machinary code?" 8 40; then
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
			string_limit_check_mark "Sugar address $sugar_address format is valid................................." "Sugar address ${GREEN}$sugar_address${CYAN} format is valid................................."
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
			string_limit_x_mark "Pool address $pool_address1 is not valid..............................."
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
			string_limit_x_mark "Miner cores $miner_cores is not valid..............................."
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
	string_limit_check_mark "Sugar address $sugar_address ................................." "Sugar address ${GREEN}$sugar_address${CYAN} ................................."
	pool_address=$(cat ${CRTDIR}/sugarchain_miner_conf.json | jq -r '.pool_address')
	string_limit_check_mark "Pool address $pool_address ................................." "Pool address ${GREEN}$pool_address${CYAN} ................................."
	miner_cores=$(cat ${CRTDIR}/sugarchain_miner_conf.json | jq -r '.miner_cores')
	string_limit_check_mark "Miner cores $miner_cores ................................." "Miner cores ${GREEN}$miner_cores${CYAN} ................................."
	machinary_code=$(cat ${CRTDIR}/sugarchain_miner_conf.json | jq -r '.machinary_code')
	string_limit_check_mark "Machinary code $machinary_code ................................." "Machinary code ${GREEN}$machinary_code${CYAN} ................................."
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
	
	check_results=`uname -a`
	if [[ $check_results =~ "Linux" ]]; then
		echo -e "${YELLOW}$check_results${NC}"
		if [[ $check_results =~ "x86_64" ]]; then
			if [[ ! -f ${CRTDIR}/sugarmaker-linux64 ]]; then
				curl -O https://raw.githubusercontent.com/bailaoshijiadao/sugarmaker/main/sugarmaker-linux64
			fi
			chmod 777 sugarmaker-linux64
			check_results=`screen -ls`
			if [[ $check_results =~ "sugarchain_screen" ]]; then
				string_limit_check_mark "Detect the existing mining serial port and start to close the original window........." "Detect the existing mining serial port and start to close the original window${GREEN}${CYAN} ........."
				Stop_sugar_miner
			fi
			
			string_limit_check_mark "Start creating a mining window............................." "Start creating a mining window${GREEN}${CYAN} ................................."
			screen_name=$"sugarchain_screen"
			screen -dmS $screen_name

			if [[ "$miner_cores" == "" ]]; then
				cmd=$"./sugarmaker-linux64 -a YespowerSugar -o stratum+tcp://$pool_address -u $sugar_address.$machinary_code"
			else
				cmd=$"./sugarmaker-linux64 -a YespowerSugar -o stratum+tcp://$pool_address -u $sugar_address.$machinary_code -t$miner_cores"
			fi
			screen -x -S $screen_name -p 0 -X stuff "$cmd"
			screen -x -S $screen_name -p 0 -X stuff $'\n'
			
			string_limit_check_mark "Sugar chain mining has been started, please press 4 after 10 seconds to enter the view mining window" "Sugar chain mining has been started, please press 4 after 10 seconds to enter the view mining window${GREEN}${CYAN}"
			sleep 5
			
		fi
		if [[ $check_results =~ "i686" ]]; then
			if [[ ! -f ${CRTDIR}/sugarmaker-linux32 ]]; then
				curl -O https://raw.githubusercontent.com/bailaoshijiadao/sugarmaker/main/sugarmaker-linux32
			fi
			chmod 777 sugarmaker-linux32
				
			check_results=`screen -ls`
			if [[ $check_results =~ "sugarchain_screen" ]]; then
				string_limit_check_mark "Detect the existing mining serial port and start to close the original window........." "Detect the existing mining serial port and start to close the original window${GREEN}${CYAN} ........."
				Stop_sugar_miner
			fi
			
			string_limit_check_mark "Start creating a mining window............................." "Start creating a mining window${GREEN}${CYAN} ................................."
			screen_name=$"sugarchain_screen"
			screen -dmS $screen_name

			if [[ "$miner_cores" == "" ]]; then
				cmd=$"./sugarmaker-linux32 -a YespowerSugar -o stratum+tcp://$pool_address -u $sugar_address.$machinary_code"
			else
				cmd=$"./sugarmaker-linux32 -a YespowerSugar -o stratum+tcp://$pool_address -u $sugar_address.$machinary_code -t$miner_cores"
			fi
			screen -x -S $screen_name -p 0 -X stuff "$cmd"
			screen -x -S $screen_name -p 0 -X stuff $'\n'
			
			string_limit_check_mark "Sugar chain mining has been started, please press 4 after 10 seconds to enter the view mining window" "Sugar chain mining has been started, please press 4 after 10 seconds to enter the view mining window${GREEN}${CYAN}"
			sleep 5
		fi
	fi
	
	echo -e "${YELLOW}******sugarmaker 2.5.0-sugar4 by Kanon******${NC}"
	echo -e "${YELLOW}Multi-threaded CPU miner for Sugarchain and other Yespower variants${NC}"
	echo -e "${YELLOW}SUGAR donation: sugar1qg3tyk3uzlet6spq9ewej6uacer0zrll0hk9dc0(bailaoshi)${NC}"
}


function Stop_sugar_miner(){
	check_results=`screen -ls`
	if [[ $check_results =~ "sugarchain_screen" ]]
	then
		screen_name=$"sugarchain_screen"
		cmd=$"\003";
		screen -x -S $screen_name -p 0 -X stuff "$cmd"
		screen -x -S $screen_name -p 0 -X stuff $'\n'
		cmd=$"exit";
		screen -x -S $screen_name -p 0 -X stuff "$cmd"
		screen -x -S $screen_name -p 0 -X stuff $'\n'
		string_limit_check_mark "Stop sugar miner succeeded....................................." "Stop sugar miner succeeded${GREEN}${CYAN} ....................................."
	else
		string_limit_x_mark "No mining window detected, stop mining failed................"
	fi
	screen -ls|awk 'NR>=2&&NR<=5{print $1}'|awk '{print "screen -S "$1" -X quit"}'|sh
}

function see_screen(){
	if screen -ls > /dev/null 2>&1
	then
		screen -r
	else
		echo -e "${RED}Mining window is not detected, window opening failed.${NC}"
	fi
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
		sudo $* install -y screen > /dev/null 2>&1
	fi
}

#Ubuntu
if [[ -f /etc/issue ]]; then
	system_v=$(cat /etc/issue)
	if [[ $system_v =~ "Ubuntu" ]]; then
		install_step apt
	fi
fi

#Centos
if [[ -f /etc/centos-release ]]; then
	install_step yum
else 
	if [[ -f /etc/redhat-release ]]; then
		install_step yum
	fi
fi




while :
do
	sleep 1
	echo -e "${BLUE}"
	figlet -f big "SugarChain"
	echo -e "${YELLOW}===========================================================${NC}"
	echo -e "${GREEN}Version: $dversion${NC}"
	echo -e "${GREEN}OS: Linux Ubuntu Centos${NC}"
	echo -e "${GREEN}Author: bailaoshi${NC}"
	echo -e "${GREEN}Special thanks to Kanon${NC}"
	echo -e "${YELLOW}===========================================================${NC}"
	echo -e "${CYAN}1  - Start sugar miner[Background process]${NC}"
	echo -e "${CYAN}2  - Stop sugar miner${NC}"
	echo -e "${CYAN}3  - Modify mining configuration[Use only when modification is required]${NC}"
	echo -e "${CYAN}4  - View the mining window, return to this window and use the key combination[CTRL+A+D]${NC}"
	echo -e "${YELLOW}===========================================================${NC}"
	echo -e "${YELLOW}******sugarmaker 2.5.0-sugar4 by Kanon******${NC}"
	echo -e "${YELLOW}Multi-threaded CPU miner for Sugarchain and other Yespower variants${NC}"
	echo -e "${YELLOW}SUGAR donation: sugar1qg3tyk3uzlet6spq9ewej6uacer0zrll0hk9dc0(bailaoshi)${NC}"

	read -rp "Pick an option and hit ENTER: "

	  case "$REPLY" in

	 1)
		sleep 2
		Start_sugar_miner
	 ;;
	 2)

		sleep 2
		Stop_sugar_miner
	 ;;
	 3) 

		sleep 2
		Modify_sugarchain_miner_conf
	 ;;
	 4) 

		sleep 2
		see_screen
	 ;;

		esac

done

