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


function creat_sugarchain_miner_conf(){

	if [[ -f /home/$USER/pool-list.json ]]; then
		echo
	else
		wget https://raw.githubusercontent.com/bailaoshijiadao/multitool-sugarchain/master/pool-list.json
	fi

	while true 
	do
		sugar_address=$(whiptail --inputbox "Please enter your sugar address" 8 85 3>&1 1>&2 2>&3)
		if [[ "$sugar_address" == sugar* ]]; then
			string_limit_check_mark "sugar address $sugar_address  format is valid................................." "sugar address ${GREEN}$sugar_address${CYAN}  format is valid................................."
			sleep 1
			break
		else
			string_limit_x_mark "Sugar address $sugar_address is not valid ..............................."
			sleep 5			
		fi
	done
	
	pool=$(cat /home/$USER/pool-list.json)
	#pool=$(curl -s https://raw.githubusercontent.com/bailaoshijiadao/multitool-sugarchain/master/pool-list.json)

	while true 
	do
		pool_address=$(whiptail --inputbox "Please enter your Pool address or IP\nChoose from the following mining pools\n$pool" 16 85 3>&1 1>&2 2>&3)
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
		miner_cores=$(whiptail --inputbox "Please enter your miner cores" 8 85 3>&1 1>&2 2>&3)
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
		machinary_code=$(whiptail --inputbox "Please enter your machinary code" 8 85 3>&1 1>&2 2>&3)
		if [[ "$machinary_code" == "" ||  "$miner_cores" == * ]]; then
			string_limit_check_mark "Machinary code $machinary_code format is valid................................." "Machinary code ${GREEN}$machinary_code${CYAN} format is valid................................."
			sleep 1
			break
		fi
	done
	
	cat << EOF >  /home/$USER/sugarchain_miner_conf.json
{
	"sugar_address":"${sugar_address}",
	"pool_address":"${pool_address}",
	"miner_cores":"${miner_cores}",
	"machinary_code":"${machinary_code}"
}
EOF

string_limit_check_mark "Modify mining configuration succeeded................................." "Modify mining configuration succeeded................................."
}


function Install_all_cpuminer(){

	sudo apt-get install -y git
	sudo apt-get install -y build-essential
	sudo apt-get install -y libssl-dev
	sudo apt-get install -y libcurl4-openssl-dev
	sudo apt-get install -y libjansson-dev
	sudo apt-get install -y libgmp-dev
	sudo apt-get install -y automake
	sudo apt-get install -y zlib1g-dev
	git clone https://github.com/cryptozeny/cpuminer-opt-sugarchain.git
	cd cpuminer-opt-sugarchain
	./build-yespower.sh

	if ./cpuminer --cputest > /dev/null 2>&1
	then
	  string_limit_check_mark " Sugarchain cpuminer installed succeeded................................." "Sugarchain cpuminer installed succeeded................................."
	  echo
	else
	  string_limit_x_mark "Sugarchain cpuminer was not installed................................."
	  echo
	  exit
	fi
}

function Install_sugarchain_cpuminer(){

if [[ $(lsb_release -d) != *Debian* && $(lsb_release -d) != *Ubuntu* ]]; then

   echo -e "${WORNING} ${CYAN}ERROR: ${RED}OS version not supported${NC}"
   echo -e "${WORNING} ${CYAN}Installation stopped...${NC}"
   echo
   exit
fi

#install JQ
if jq --version > /dev/null 2>&1; then
	string_limit_check_mark "JQ $(jq --version) already installed................................." "JQ ${GREEN}$(jq --version)${CYAN} already installed................................."
	sleep 0.2
else
  echo -e "${ARROW} ${YELLOW}Installing JQ....${NC}"
  sudo apt  install jq -y > /dev/null 2>&1

    if jq --version > /dev/null 2>&1
    then
      string_limit_check_mark "JQ $(jq --version) installed................................." "JQ ${GREEN}$(jq --version)${CYAN} installed................................."
      echo
    else
      string_limit_x_mark "JQ was not installed................................."
      echo
      exit
    fi
fi

#Are mining files installed
if [[ -d /home/$USER/cpuminer-opt-sugarchain ]]; then
	echo -e "${CYAN}Detect that the folder cpuminer-opt-sugarchain already exists${NC}"
	echo -e "${CYAN}Start test whether the mining software is installed correctly${NC}"
	cd cpuminer-opt-sugarchain
	if ./cpuminer --cputest > /dev/null 2>&1
	then
	  string_limit_check_mark " Sugarchain cpuminer is already installed................................." "Sugarchain is already cpuminer installed................................."
	  echo
	  exit
	else
	  string_limit_x_mark "Sugarchain cpuminer was not installed................................."
	  echo
	fi
fi


#creat sugarchain_miner_conf.json
if [[ -f /home/$USER/sugarchain_miner_conf.json ]]; then
	if whiptail --yesno "Would you like import old settings from sugarchain_conf?" 8 65; then
		read_config
		Install_all_cpuminer
	else
		creat_sugarchain_miner_conf
		Install_all_cpuminer
	fi
else
	creat_sugarchain_miner_conf
	Install_all_cpuminer
fi

}



function read_config(){
	sugar_address=$(cat /home/$USER/sugarchain_miner_conf.json | jq -r '.sugar_address')
	string_limit_check_mark "sugar_address $sugar_address ................................." "sugar_address ${GREEN}$sugar_address${CYAN} ................................."
	pool_address=$(cat /home/$USER/sugarchain_miner_conf.json | jq -r '.pool_address')
	string_limit_check_mark "pool_address $pool_address ................................." "pool_address ${GREEN}$pool_address${CYAN} ................................."
	miner_cores=$(cat /home/$USER/sugarchain_miner_conf.json | jq -r '.miner_cores')
	string_limit_check_mark "miner_cores $miner_cores ................................." "miner_cores ${GREEN}$miner_cores${CYAN} ................................."
	machinary_code=$(cat /home/$USER/sugarchain_miner_conf.json | jq -r '.machinary_code')
	string_limit_check_mark "machinary code $machinary_code ................................." "machinary code ${GREEN}$machinary_code${CYAN} ................................."
}


function Start_sugar_miner(){
	if screen -ls > /dev/null 2>&1
	then
	  Stop_sugar_miner
	  echo
	fi
	echo -e "${CYAN}Sugarchain cpuminer setup starting,you can press [CTRL+C] to cancel.${NC}"
	sleep 5
	cd ~/
	if [[ -f /home/$USER/sugarchain_miner_conf.json ]]; then
		read_config
	else
		creat_sugarchain_miner_conf
	fi
	
	if [[ "$sugar_address" == "" || "$sugar_address" != sugar* ]]; then
		creat_sugarchain_miner_conf
	fi
	if [[ "$pool_address" == "" || "$pool_address" != *.*.*:* || "$pool_address" != *.*.*.*:* ]]; then
		creat_sugarchain_miner_conf
	fi
	
	if [[ -d /home/$USER/cpuminer-opt-sugarchain ]]; then
		echo -e "${CYAN}Detect that the folder cpuminer-opt-sugarchain already exists${NC}"
		echo -e "${CYAN}Start test whether the mining software is installed correctly${NC}"
		cd cpuminer-opt-sugarchain
		if ./cpuminer --cputest > /dev/null 2>&1
		then
		  string_limit_check_mark " Sugarchain cpuminer is already installed................................." "Sugarchain is already cpuminer installed................................."
		  echo
		else
		  string_limit_x_mark "Sugarchain cpuminer was not installed................................."
		  rm -rf /home/$USER/cpuminer-opt-sugarchain
		  Install_all_cpuminer
		  echo
		fi
	else
		Install_all_cpuminer
	fi

	screen_name=$"my_screen"
	screen -dmS $screen_name
	cmd=$"cd ~/cpuminer-opt-sugarchain";
	screen -x -S $screen_name -p 0 -X stuff "$cmd"
	screen -x -S $screen_name -p 0 -X stuff $'\n'
	
	if [[ "$miner_cores" == "" ]]; then
		cmd=$"./cpuminer -a yespower -o stratum+tcp://$pool_address -u $sugar_address.$machinary_code"
	else
		cmd=$"./cpuminer -a yespower -o stratum+tcp://$pool_address -u $sugar_address.$machinary_code -t$miner_cores"
	fi
	screen -x -S $screen_name -p 0 -X stuff "$cmd"
	screen -x -S $screen_name -p 0 -X stuff $'\n'
	string_limit_check_mark "Start sugar miner succeeded................................." "Start sugar miner succeeded${GREEN}${CYAN} ................................."
	echo -e "${YELLOW}************  cpuminer-opt v3.8.8.1.7-sugarchain  ************* ${NC}"
	echo -e "${YELLOW}   A CPU miner with multi algo support and optimized for CPUs   ${NC}"
	echo -e "${YELLOW}            with AES_NI and AVX2 and SHA extensions.            ${NC}"
	echo -e "${YELLOW}            with AES_NI and AVX2 and SHA extensions.            ${NC}"
	echo -e "${YELLOW}SUGAR donation: sugar1qg3tyk3uzlet6spq9ewej6uacer0zrll0hk9dc0 (bailaoshi)${NC}"
	echo -e "${YELLOW}To view, copy and paste the command \"screen -r\", and then enter${NC}"
}

function Stop_sugar_miner(){
	
	if screen -ls > /dev/null 2>&1
	then
		screen_name=$"my_screen"
		cmd=$"\003";
		screen -x -S $screen_name -p 0 -X stuff "$cmd"
		screen -x -S $screen_name -p 0 -X stuff $'\n'
		cmd=$"exit";
		screen -x -S $screen_name -p 0 -X stuff "$cmd"
		screen -x -S $screen_name -p 0 -X stuff $'\n'
		string_limit_check_mark "Stop sugar miner succeeded................................." "Stop sugar miner succeeded${GREEN}${CYAN} ................................."
	echo
	fi
}


if ! figlet -v > /dev/null 2>&1
then
sudo apt-get update -y > /dev/null 2>&1
sudo apt-get install -y figlet > /dev/null 2>&1
fi

if ! screen -v > /dev/null 2>&1
then
sudo sudo apt-get install screen > /dev/null 2>&1
fi


sleep 1
echo -e "${BLUE}"
figlet -f big "SugarChain"
echo -e "${YELLOW}================================================================${NC}"
echo -e "${GREEN}Version: $dversion${NC}"
echo -e "${GREEN}OS: Ubuntu 16/18${NC}"
echo -e "${GREEN}Author:bailaoshi${NC}"
echo -e "${GREEN}Special thanks to cryptozeny${NC}"
echo -e "${YELLOW}================================================================${NC}"
echo -e "${CYAN}1  - Start sugar miner${NC}"
echo -e "${CYAN}2  - STOP sugar miner${NC}"
echo -e "${CYAN}3  - Modify mining configuration${NC}"
echo -e "${YELLOW}================================================================${NC}"
echo -e "${YELLOW}************  cpuminer-opt v3.8.8.1.7-sugarchain  ************* ${NC}"
echo -e "${YELLOW}   A CPU miner with multi algo support and optimized for CPUs   ${NC}"
echo -e "${YELLOW}            with AES_NI and AVX2 and SHA extensions.            ${NC}"
echo -e "${YELLOW}            with AES_NI and AVX2 and SHA extensions.            ${NC}"
echo -e "${YELLOW}SUGAR donation: sugar1qg3tyk3uzlet6spq9ewej6uacer0zrll0hk9dc0 (bailaoshi)${NC}"

read -rp "Pick an option and hit ENTER: "

  case "$REPLY" in

 1)
    sleep 1
    Start_sugar_miner
 ;;
 2) 

    sleep 1
    Stop_sugar_miner
 ;;
  3) 

    sleep 1
    creat_sugarchain_miner_conf
 ;;

    esac
