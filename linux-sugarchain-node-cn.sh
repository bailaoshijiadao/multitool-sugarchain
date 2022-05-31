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

function Start_sugar_node(){
	echo -e "${CYAN}糖链节点安装程序启动时,您可以按[CTRL+C]取消${NC}"
	sleep 5
	cd ~/
	
	if [[ ! -d ${CRTDIR}/.sugarchain ]]; then
		mkdir -p ${CRTDIR}/.sugarchain
	fi

	cat << EOF >  ${CRTDIR}/.sugarchain/sugarchain.conf
{
	server=1
	rpcuser=baihe
	rpcpassword=passwordbaihe
	rpcallowip=127.0.0.1
}
EOF

	check_results=`uname -a`
	if [[ $check_results =~ "Linux" ]]; then
		echo -e "${YELLOW}$check_results${NC}"
		if [[ $check_results =~ "x86_64" ]]; then
			if [[ ! -d ${CRTDIR}/sugarchain-0.16.3 ]]; then
				wget https://github.com/sugarchain-project/sugarchain/releases/download/v0.16.3.36-payapoya/sugarchain-0.16.3.36-payapoya-x86_64-linux-gnu.tar.gz
				tar -zxvf sugarchain-0.16.3.36-payapoya-x86_64-linux-gnu.tar.gz
			fi
		fi
		if [[ $check_results =~ "i686" ]]; then
			if [[ ! -d ${CRTDIR}/sugarchain-0.16.3 ]]; then
				#curl -O https://gitee.com/bailaoshijiadao/sugarmaker/raw/main/sugarmaker-linux32
				wget https://github.com/sugarchain-project/sugarchain/releases/download/v0.16.3.36-payapoya/sugarchain-0.16.3.36-payapoya-i686-pc-linux-gnu.tar.gz
				tar -zxvf sugarchain-0.16.3.36-payapoya-i686-pc-linux-gnu.tar.gz
			fi
		fi
	fi
	
	if [[ -d ${CRTDIR}/sugarchain-0.16.3 ]]; then
		cd ${CRTDIR}/sugarchain-0.16.3
	fi
	
	~/sugarchain-0.16.3/bin/sugarchaind
	
}


function Stop_sugar_miner(){
	cd ~/
	~/sugarchain-0.16.3/bin/sugarchain-cli stop
}

function install_step(){
	if ! figlet -v > /dev/null 2>&1; then
		echo -e "${ARROW} ${YELLOW}安装 figlet 中 ....${NC}"
		sudo $* install -y figlet > /dev/null 2>&1
	fi


	if ! whiptail -v > /dev/null 2>&1; then
		echo -e "${ARROW} ${YELLOW}安装 whiptail 中....${NC}"
		sudo $* install -y whiptail > /dev/null 2>&1
	fi

	#install JQ
	if ! jq --version > /dev/null 2>&1; then
		echo -e "${ARROW} ${YELLOW}安装 JQ 中 ....${NC}"
		sudo $* install -y jq > /dev/null 2>&1
	fi

	if ! screen -v > /dev/null 2>&1; then
		echo -e "${ARROW} ${YELLOW}安装 screen 中 ....${NC}"
		sudo $* install -y screen > /dev/null 2>&1
	fi
	
	if ! wget --version > /dev/null 2>&1; then
		echo -e "${ARROW} ${YELLOW}安装 wget 中 ....${NC}"
		sudo $* install -y wget > /dev/null 2>&1
	fi
	if ! git --version > /dev/null 2>&1; then
		echo -e "${ARROW} ${YELLOW}安装 git 中 ....${NC}"
		sudo $* install -y git > /dev/null 2>&1
	fi
	
	#if ! node -v > /dev/null 2>&1; then
		#echo -e "${ARROW} ${YELLOW}安装 nodejs 中 ....${NC}"
		#curl --silent --location https://rpm.nodesource.com/setup_10.x | sudo bash > /dev/null 2>&1
		#sudo $* install -y nodejs > /dev/null 2>&1
	#fi
}

#Ubuntu
if [[ -f /etc/issue ]]; then
	system_v=$(cat /etc/issue)
	if [[ $system_v =~ "Ubuntu" ]]; then
		echo -e "${YELLOW}apt${NC}"
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




while :
do
	sleep 1
	echo -e "${BLUE}"
	figlet -f big "SugarChain"
	echo -e "${YELLOW}===========================================================${NC}"
	echo -e "${GREEN}版本: $dversion${NC}"
	echo -e "${GREEN}系统: Linux Ubuntu Centos${NC}"
	echo -e "${GREEN}作者: bailaoshi${NC}"
	echo -e "${YELLOW}===========================================================${NC}"
	echo -e "${CYAN}1  - 启动糖链节点[包含安装过程]${NC}"
	echo -e "${CYAN}2  - 停止糖链节点${NC}"
	echo -e "${CYAN}3  - 查看钱包当前区块数量${NC}"
	echo -e "${CYAN}4  - 查看节点连接数${NC}"
	echo -e "${YELLOW}===========================================================${NC}"
	echo -e "${YELLOW}******糖链一健创建节点******${NC}"
	echo -e "${YELLOW}糖捐助地址: sugar1qg3tyk3uzlet6spq9ewej6uacer0zrll0hk9dc0(bailaoshi)${NC}"

	read -rp "请输入数字选项并按回车键: "

	  case "$REPLY" in

	 1)
		sleep 2
		Start_sugar_node
	 ;;
	 2)

		sleep 2
		Stop_sugar_node
	 ;;
	 3) 

		sleep 2
		~/sugarchain-0.16.3/bin/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe getblockcount
	 ;;
	 4) 

		sleep 2
		~/sugarchain-0.16.3/bin/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe getconnectioncount
	 ;;

		esac

done

