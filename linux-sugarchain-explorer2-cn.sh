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

ip=`curl --connect-timeout 10 -m 20 -s http://whatismyip.akamai.com/`

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

function Start_sugar_explorer(){
	CRON_LINE="cd sugarchain-blockchain-explorer2 && pm2 start ./bin/www --name sugarchain-blockchain-explorer2"
	CRON_EXISTS=$(crontab -l | grep "$CRON_LINE" | wc -l)
	if [ $CRON_EXISTS -eq 0 ]
	then
		crontab -l | { cat; echo "@reboot $CRON_LINE"; } | crontab -
		string_limit_check_mark "开机启动任务设置完成........." "开机启动任务设置完成.........${GREEN}${CYAN} ........."
	else
		string_limit_check_mark "已有开机启动任务........." "已有开机启动任务${GREEN}${CYAN} ........."
	fi
	
	#install nvm
	if ! nvm --version > /dev/null 2>&1; then
		echo -e "${ARROW} ${YELLOW}安装 nvm 中 ....${NC}"
		unset NVM_DIR
		cd
		curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.9/install.sh | bash
		source /etc/profile
		profile_LINE="NVM_DIR/nvm.sh"
		profile_EXISTS=$(cat /etc/profile | grep "$profile_LINE" | wc -l)
		if [ $profile_EXISTS -eq 0 ]
		then
			echo 'export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> /etc/profile
			source /etc/profile
			string_limit_check_mark "nvm 配置写入成功........." "nvm 配置写入成功${GREEN}${CYAN} ........."
		fi
		source /etc/profile
	fi

	#install node
	if ! node -v > /dev/null 2>&1; then
		echo -e "${ARROW} ${YELLOW}安装 node 中....${NC}"
		nvm install v12.14.0
	fi
	
	if [[ ! -d ${CRTDIR}/sugarchain-blockchain-explorer2 ]]; then
		git clone https://github.com/bailaoshijiadao/sugarchain-blockchain-explorer2
	fi
	
	pm2 save --force
	pm2_flag=`pm2 list`
	if [[ $pm2_flag =~ "sugarchain-blockchain-explorer2" ]]; then
		echo -e "${ARROW} ${YELLOW}糖链区块浏览器 2 已经存在....${NC}"
		string_limit_check_mark "http://$ip:3099" "http://$ip:3099${GREEN}${CYAN} ......"
	else
		cd sugarchain-blockchain-explorer2
		npm install
		npm install pm2 -g
		pm2 start ./bin/www --name sugarchain-blockchain-explorer2
		pm2 startup
		string_limit_check_mark "http://$ip:3099" "http://$ip:3099${GREEN}${CYAN} ......"
	fi
}

function install_step(){

	if ! figlet -v > /dev/null 2>&1; then
		echo -e "${ARROW} ${YELLOW}安装 figlet 中 ....${NC}"
		sudo $* install -y figlet
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
}

function explorer2_domain(){
	read -p "输入你的域名,没有http://或https://前缀,例如 explorer2.example.com: " domain
	
	#Ubuntu
	if [[ -f /etc/issue ]]; then
		system_v=$(cat /etc/issue)
		if [[ $system_v =~ "Ubuntu" ]]; then
			echo -e "${YELLOW}apt${NC}"
			sudo apt-get update
			sudo apt install nginx snapd -y
		fi
	fi
	
	#Centos
	if [[ -f /etc/centos-release ]]; then
		echo -e "${YELLOW}yum${NC}"
		sudo yum install nginx -y
	else 
		if [[ -f /etc/redhat-release ]]; then
			echo -e "${YELLOW}yum${NC}"
			sudo yum install nginx snapd -y
		fi
	fi
	
	sudo unlink /etc/nginx/sites-enabled/$domain.conf
	rm -rf /etc/nginx/sites-available/$domain.conf
	if [[ ! -f /etc/nginx/sites-available/$domain.conf ]]; then
		cat << EOF >  /etc/nginx/sites-available/$domain.conf
server {
    server_name $domain;

    location / {
        proxy_pass http://localhost:3099;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    location /socket.io {
        include proxy_params;
        proxy_http_version 1.1;
        proxy_buffering off;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_pass http://127.0.0.1:3099/socket.io;
    }

    listen 80;
}
EOF
	fi
	
	sudo ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled
	sudo snap install --classic certbot
	sudo certbot --nginx -d $domain
	
	string_limit_check_mark "https://$domain" "https://$domain${GREEN}${CYAN} ......"
}

if ! node -version > /dev/null 2>&1 ; then
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
	echo -e "${CYAN}1  - 启动糖链区块浏览器2 [包含安装过程]${NC}"
	echo -e "${CYAN}2  - 查看区块浏览器2资源的使用情况${NC}"
	echo -e "${CYAN}3  - 删除区块浏览器2的PM2应用程序${NC}"
	echo -e "${CYAN}4  - 区块浏览器2重新启动${NC}"
	echo -e "${CYAN}5  - 查看区块浏览器2运行日志${NC}"
	echo -e "${CYAN}6  - 查看区块浏览器2运行详细信息${NC}"
	echo -e "${CYAN}7  - 停止区块浏览器2${NC}"
	echo -e "${CYAN}8  - 设置区块浏览器2的域名${NC}"
	echo -e "${YELLOW}===========================================================${NC}"
	echo -e "${YELLOW}******糖链一键创建 explorer2 区块浏览器脚本******${NC}"
	echo -e "${YELLOW}糖捐助地址: sugar1q8d79pk0jyhl92jrmfsrpvuwwg9ycsr20xz93rz(bailaoshi)${NC}"

	read -rp "请输入数字选项并按回车键: "

	  case "$REPLY" in

	 1)
		sleep 2
		Start_sugar_explorer
	 ;;
	 2)

		sleep 2
		pm2 monit
	 ;;
	 3) 

		sleep 2
		pm2 delete sugarchain-blockchain-explorer2
	 ;;
	 4) 

		sleep 2
		pm2 startOrReload sugarchain-blockchain-explorer2
	 ;;
	 5) 

		sleep 2
		pm2 logs sugarchain-blockchain-explorer2
	 ;;
	 6) 

		sleep 2
		pm2 show sugarchain-blockchain-explorer2
	 ;;
	 7)
		sleep 2
		pm2 stop sugarchain-blockchain-explorer2
	 ;;
	 8)
		sleep 2
		explorer2_domain
	 ;;

		esac

done

