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

CUR_PATH=$(cd "$(dirname "$0")"; pwd)

# 要定时执行的任务
TASK_COMMAND="cat /dev/null > ${CRTDIR}/.sugarchain/debug.log"
# 要添加的crontab任务
CRONTAB_TASK="*/3000 * * * * ${TASK_COMMAND}"
# 备份原始crontab记录文件
CRONTAB_BAK_FILE="${CUR_PATH}/crontab_bak"

# 创建crontab任务函数
function create_crontab()
{
	crontab_results=`crontab -l`
	if [[ ! $crontab_results =~ "/.sugarchain/debug.log" ]]; then
		echo -e "${CYAN}开始创建定时定时清除日志任务${NC}"
		echo "${CRONTAB_TASK}" >> ${CRONTAB_BAK_FILE}
		crontab ${CRONTAB_BAK_FILE}
		string_limit_check_mark "定时定时清除日志任务完成........." "定时定时清除日志任务完成${GREEN}${CYAN} ........."
	else
		string_limit_check_mark "已有定时任务........." "已有定时任务${GREEN}${CYAN} ........."
	fi
}

function update_sugar_node(){
	echo -e "${CYAN}开始更新节点配置文件${NC}"
	cat << EOF >  ${CRTDIR}/.sugarchain/sugarchain.conf
server=1
rpcuser=baihe
rpcpassword=passwordbaihe
rpcallowip=127.0.0.1

addnode=222.186.175.58
addnode=45.195.149.108
EOF
	string_limit_check_mark "节点配置文件更新成功........." "节点配置文件更新成功${GREEN}${CYAN} ........."
}

function Start_sugar_node(){
	echo -e "${CYAN}糖链节点安装程序启动时,您可以按[CTRL+C]取消${NC}"
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
		if ! ${CRTDIR}/sugarwallet-linux${system_bits}/bin/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe getblockcount > /dev/null 2>&1 ; then
			screen -ls|awk 'NR>=2&&NR<=5{print $1}'|awk '{print "screen -S "$1" -X quit"}'|sh
			string_limit_check_mark "开始创建节点窗口............................." "开始创建节点窗口${GREEN}${CYAN} ................................."
			screen_name=$"sugarchain_node"
			screen -dmS $screen_name
			cmd=$"~/sugarwallet-linux${system_bits}/bin/sugarchaind"		
			screen -x -S $screen_name -p 0 -X stuff "$cmd"
			screen -x -S $screen_name -p 0 -X stuff $'\n'
			sleep 5
			if ${CRTDIR}/sugarwallet-linux${system_bits}/bin/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe -version > /dev/null 2>&1 ; then
				string_limit_check_mark "已启动糖链节点,请10秒后输入其他数字查看节点状态......" "已启动糖链节点,请10秒后输入其他数字查看节点状态${GREEN}${CYAN} ......"
			fi
			sleep 5
		else
			string_limit_check_mark "检测节点已启动,无需重复启动........." "检测节点已启动,无需重复启动${GREEN}${CYAN} ........."
			sleep 5
		fi
	fi
}

function Stop_sugar_node(){
	cd ~/
	echo -e "${ARROW} ${YELLOW}开始关闭糖链节点 ....${NC}"
	${CRTDIR}/sugarwallet-linux${system_bits}/bin/sugarchain-cli stop
	screen -ls|awk 'NR>=2&&NR<=5{print $1}'|awk '{print "screen -S "$1" -X quit"}'|sh
	string_limit_check_mark "关闭糖链节点成功......" "关闭糖链节点成功${GREEN}${CYAN} ......"
	sleep 5
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
	
	
	if ! ls -lh /swapfile > /dev/null 2>&1; then
		sudo fallocate -l 8G /swapfile
	fi
	
	sudo chmod 755 /swapfile
	sudo mkswap /swapfile
	sudo swapon /swapfile
	sudo swapon -s
	
	swapfile_flag=`cat /etc/fstab`
	if [[ $swapfile_flag =~ "swapfile" ]]; then
		echo -e "${ARROW} ${YELLOW}虚拟内存已开机自动挂载,无需重新设置....${NC}"
	else
		sed -i '$a /swapfile  none  swap  sw  0  0' /etc/fstab
		echo -e "${ARROW} ${YELLOW}虚拟内存开机自动挂载设置成功....${NC}"
	fi

}

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

create_crontab

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
	echo -e "${CYAN}2  - 更新节点配置文件[根据黑猫文件更新内容]${NC}"
	echo -e "${CYAN}3  - 查看钱包当前区块数量${NC}"
	echo -e "${CYAN}4  - 查看节点连接数${NC}"
	echo -e "${CYAN}5  - 查看钱包版本${NC}"
	echo -e "${CYAN}6  - 查看区块头下载进度${NC}"
	echo -e "${CYAN}7  - 停止糖链节点${NC}"
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

