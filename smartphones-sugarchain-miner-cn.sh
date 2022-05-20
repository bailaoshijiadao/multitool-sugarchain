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
		curl -O https://gitee.com/bailaoshijiadao/multitool-sugarchain/raw/main/pool-list.json
	fi
	
	if whiptail --yesno "是否继续使用旧的钱包地址?" 8 40; then
		string_limit_check_mark "糖钱包地址 $sugar_address................................." "糖钱包地址 ${GREEN}$sugar_address${CYAN}................................."
		sleep 2
	else
		while true 
		do
			sugar_address=$(whiptail --inputbox "请输入你的糖钱包地址" 8 40 3>&1 1>&2 2>&3)
			if [[ "$sugar_address" == sugar* ]]; then
				string_limit_check_mark "糖钱包地址 $sugar_address  格式有效................................." "糖钱包地址 ${GREEN}$sugar_address${CYAN}  格式有效................................."
				sleep 1
				break
			else
				string_limit_x_mark "糖钱包地址 $sugar_address 格式错误..............................."
				sleep 5			
			fi
		done
	fi
	
	pool=$(cat ${CRTDIR}/pool-list.json)
	#pool=$(curl -O https://gitee.com/bailaoshijiadao/multitool-sugarchain/raw/main/pool-list.json)
	
	if whiptail --yesno "是否继续使用旧的矿池?" 8 40; then
		string_limit_check_mark "矿池地址 $pool_address................................." "矿池地址 ${GREEN}$pool_address${CYAN}................................."
		sleep 2
	else
		while true 
		do
			pool_address=$(whiptail --inputbox "请输入你的矿池地址或IP\n可以从下列中选择,中国可选择默认填入的矿池\n$pool" 16 40 39.98.39.1:6678 3>&1 1>&2 2>&3)
			if [[ "$pool_address" == *.*.*:* || "$pool_address" == *.*.*.*:* ]]; then
				string_limit_check_mark "矿池地址 $pool_address 格式有效................................." "矿池地址 ${GREEN}$pool_address${CYAN} 格式有效................................."
				sleep 1
				break
			else
				string_limit_x_mark "矿池地址 $pool_address1 格式错误..............................."
				sleep 5
			fi
		done
	fi
	
	if whiptail --yesno "是否继续使用旧的挖矿核心数?" 8 40; then
		string_limit_check_mark "开采核心数 $miner_cores................................." "开采核心数 ${GREEN}$miner_cores${CYAN}................................."
		sleep 2
	else
		while true 
		do
			miner_cores=$(whiptail --inputbox "请输入你的开采核心数(可空), 不填则为100%开采" 8 40 3>&1 1>&2 2>&3)
			if [[ "$miner_cores" =~ ^[0-9]*$ ||  "$miner_cores" == "" ]]; then
				string_limit_check_mark "开采核心数 $miner_cores 格式有效................................." "开采核心数 ${GREEN}$miner_cores${CYAN} 格式有效................................."
				sleep 1
				break
			else
				string_limit_x_mark "开采核心数 $miner_cores 格式错误..............................."
				sleep 5
			fi
		done
	fi
	
	if whiptail --yesno "是否继续使用旧的机器编号?" 8 40; then
		string_limit_check_mark "机器编号 $machinary_code................................." "机器编号 ${GREEN}$machinary_code${CYAN}................................."
		sleep 2
	else
		while true 
		do
			machinary_code=$(whiptail --inputbox "请输入你的机器编号(可空)" 8 40 3>&1 1>&2 2>&3)
			if [[ "$machinary_code" == "" ||  "$miner_cores" == * ]]; then
				string_limit_check_mark "机器编号 $machinary_code 格式有效................................." "机器编号 ${GREEN}$machinary_code${CYAN} 格式有效................................."
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

string_limit_check_mark "修改开采配置成功................................." "修改开采配置成功................................."
}


function creat_sugarchain_miner_conf(){

	if [[ -f ${CRTDIR}/pool-list.json ]]; then
		echo
	else
		curl -O https://gitee.com/bailaoshijiadao/multitool-sugarchain/raw/main/pool-list.json
		
	fi
	
	while true 
	do
		sugar_address=$(whiptail --inputbox "请输入你的糖钱包地址" 8 40 3>&1 1>&2 2>&3)
		if [[ "$sugar_address" == sugar* ]]; then
			string_limit_check_mark "糖钱包地址 $sugar_address 格式有效................................." "糖钱包地址 ${GREEN}$sugar_address${CYAN} 格式有效................................."
			sleep 1
			break
		else
			string_limit_x_mark "糖钱包地址 $sugar_address 格式错误 ..............................."
			sleep 5			
		fi
	done
	
	pool=$(cat ${CRTDIR}/pool-list.json)
	#pool=$(curl -O https://gitee.com/bailaoshijiadao/multitool-sugarchain/raw/main/pool-list.json)
	
	while true 
	do
		pool_address=$(whiptail --inputbox "请输入你的矿池地址或IP\n可以从下列中选择,中国可选择默认填入的矿池\n$pool" 16 40 39.98.39.1:6678 3>&1 1>&2 2>&3)
		if [[ "$pool_address" == *.*.*:* || "$pool_address" == *.*.*.*:* ]]; then
			string_limit_check_mark "矿池地址 $pool_address 格式有效................................." "矿池地址 ${GREEN}$pool_address${CYAN} 格式有效................................."
			sleep 1
			break
		else
			string_limit_x_mark "矿池地址 $pool_address1 格式错误..............................."
			sleep 5
		fi
	done
	
	while true 
	do
		miner_cores=$(whiptail --inputbox "请输入你的开采核心数(可空), 不填则为100%开采" 8 40 3>&1 1>&2 2>&3)
		if [[ "$miner_cores" =~ ^[0-9]*$ ||  "$miner_cores" == "" ]]; then
			string_limit_check_mark "开采核心数 $miner_cores 格式有效................................." "开采核心数 ${GREEN}$miner_cores${CYAN} 格式有效................................."
			sleep 1
			break
		else
			string_limit_x_mark "开采核心数 $miner_cores 格式错误..............................."
			sleep 5
		fi
	done
	
	while true 
	do
		machinary_code=$(whiptail --inputbox "请输入你的机器编号(可空)" 8 40 3>&1 1>&2 2>&3)
		if [[ "$machinary_code" == "" ||  "$miner_cores" == * ]]; then
			string_limit_check_mark "机器编号 $machinary_code 格式有效................................." "机器编号 ${GREEN}$machinary_code${CYAN} 格式有效................................."
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

string_limit_check_mark "创建开采配置成功................................." "创建开采配置成功................................."
}


function read_config(){
	sugar_address=$(cat ${CRTDIR}/sugarchain_miner_conf.json | jq -r '.sugar_address')
	string_limit_check_mark "糖钱包地址 $sugar_address ................................." "糖钱包地址 ${GREEN}$sugar_address${CYAN} ................................."
	pool_address=$(cat ${CRTDIR}/sugarchain_miner_conf.json | jq -r '.pool_address')
	string_limit_check_mark "矿池地址 $pool_address ................................." "矿池地址 ${GREEN}$pool_address${CYAN} ................................."
	miner_cores=$(cat ${CRTDIR}/sugarchain_miner_conf.json | jq -r '.miner_cores')
	string_limit_check_mark "开采核心数 $miner_cores ................................." "开采核心数 ${GREEN}$miner_cores${CYAN} ................................."
	machinary_code=$(cat ${CRTDIR}/sugarchain_miner_conf.json | jq -r '.machinary_code')
	string_limit_check_mark "机器编号 $machinary_code ................................." "机器编号 ${GREEN}$machinary_code${CYAN} ................................."
}


function Start_sugar_miner(){
	echo -e "${CYAN}糖链开采安装程序启动时,您可以按[CTRL+C]取消${NC}"
	sleep 5
	cd ~/
	
	if [[ -f ${CRTDIR}/sugarchain_miner_conf.json ]]; then
		read_config
	else
		creat_sugarchain_miner_conf
	fi
	
	if [[ ! -f ${CRTDIR}/sugarchain-aarch64 ]]; then
		curl -O https://gitee.com/bailaoshijiadao/sugarchain-aarch64/raw/main/sugarchain-aarch64
		chmod 777 sugarchain-aarch64
	fi
	
	if [[ "$miner_cores" == "" ]]; then
		./sugarchain-aarch64 -o stratum+tcp://$pool_address -u $sugar_address
	else
		./sugarchain-aarch64 -o stratum+tcp://$pool_address -u $sugar_address.$machinary_code
	fi
	
	sleep 10
	
	string_limit_check_mark "已启动糖链开采,请自行看屏幕提示是否启动成功................................." "已启动糖链开采,请自行看屏幕提示是否启动成功${GREEN}${CYAN} ................................."
	echo -e "${YELLOW}******sugarmaker 2.5.0-sugar4 by Kanon******${NC}"
	echo -e "${YELLOW}适用于糖链和其他Yespower算法的多线程CPU开采${NC}"
	echo -e "${YELLOW}糖捐助地址: sugar1qg3tyk3uzlet6spq9ewej6uacer0zrll0hk9dc0(bailaoshi)${NC}"
}


echo -e "${CYAN}开始更换国内源并更新程序${NC}"
sleep 2
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.bfsu.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list &&sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.bfsu.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list &&sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.bfsu.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list
	

if ! figlet -v > /dev/null 2>&1; then
	echo -e "${ARROW} ${YELLOW}安装 figlet 中....${NC}"
	pkg install -y figlet > /dev/null 2>&1
fi


if ! whiptail -v > /dev/null 2>&1; then
	echo -e "${ARROW} ${YELLOW}安装 whiptail 中....${NC}"
	apt install whiptail -y > /dev/null 2>&1
fi

#install JQ
if ! jq --version > /dev/null 2>&1; then
	echo -e "${ARROW} ${YELLOW}安装 JQ 中....${NC}"
	apt install jq -y > /dev/null 2>&1
fi

sleep 1
echo -e "${BLUE}"
figlet -f big "SugarChain"
echo -e "${YELLOW}================================================================${NC}"
echo -e "${GREEN}版本: $dversion${NC}"
echo -e "${GREEN}系统: Android > 7.0${NC}"
echo -e "${GREEN}作者:bailaoshi${NC}"
echo -e "${GREEN}特别感谢 Kanon${NC}"
echo -e "${YELLOW}================================================================${NC}"
echo -e "${CYAN}1  - 启动糖链开采[包含安装]${NC}"
echo -e "${CYAN}2  - 修改开采配置${NC}"
echo -e "${YELLOW}================================================================${NC}"
echo -e "${YELLOW}******sugarmaker 2.5.0-sugar4 by Kanon******${NC}"
echo -e "${YELLOW}适用于糖链和其他Yespower算法的多线程CPU开采${NC}"
echo -e "${YELLOW}糖捐助地址: sugar1qg3tyk3uzlet6spq9ewej6uacer0zrll0hk9dc0(bailaoshi)${NC}"

read -rp "选择一个选项并按回车键: "

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
