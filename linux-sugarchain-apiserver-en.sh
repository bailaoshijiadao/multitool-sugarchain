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
	echo -e "${CYAN}When the sugar chain API node installation program starts,You can press [CTRL+C] to cancel${NC}"
	sleep 5
	cd ~/
	
	python_version=$(python3.8 --version)
	if [[ $python_version != "Python 3.8.0" ]]; then
		echo -e "${ARROW} ${YELLOW}Installing python3 ....${NC}"
		
		#Down python
		if [[ ! -d ${CRTDIR}/Python-3.8.0 ]]; then
			wget https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz
			tar -xvf Python-3.8.0.tgz
		fi
		
		
		cd Python-3.8.0/
		./configure --enable-optimizations
		make
		sudo make altinstall

	fi
	
	if [[ ! -d ${CRTDIR}/.sugarchain ]]; then
		mkdir -p ${CRTDIR}/.sugarchain
	fi
	
	if [[ ! -f ${CRTDIR}/.sugarchain/sugarchain.conf ]]; then
		update_sugar_node
	fi
	
	if [[ ! -d ${CRTDIR}/sugarchain-API-addressindex ]]; then
		cd
		git clone https://github.com/bailaoshijiadao/sugarchain-API-addressindex.git
		chmod 755 ${CRTDIR}/sugarchain-API-addressindex/sugarchain-cli
		chmod 755 ${CRTDIR}/sugarchain-API-addressindex/sugarchaind
	fi
	
	cd ${CRTDIR}/sugarchain-API-addressindex/
	#check sha256sum hash 
	if [[ `sha256sum -c sugarchaind.sha256` == "sugarchaind: OK" ]]; then
		string_limit_check_mark "File sugarchaind sha256 verification passed........." "File sugarchaind sha256 verification passed${GREEN}${CYAN} ........."
	else
		string_limit_x_mark "File sugarchaind sha256 verification failed........." "File sugarchaind sha256 verification failed${RED}${CYAN} ........."
		exit 0
	fi
	if [[ `sha256sum -c sugarchain-cli.sha256` == "sugarchain-cli: OK" ]]; then
		string_limit_x_mark "File sugarchain-cli sha256 verification failed........." "File sugarchain-cli sha256 verification failed${RED}${CYAN} ........."
	else
		exit 0
	fi

	if [[ -d ${CRTDIR}/sugarchain-API-addressindex ]]; then
		if ! ${CRTDIR}/sugarchain-API-addressindex/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe getconnectioncount > /dev/null 2>&1 ; then
			#screen -ls|awk 'NR>=2&&NR<=5{print $1}'|awk '{print "screen -S "$1" -X quit"}'|sh	
			${CRTDIR}/sugarchain-API-addressindex/sugarchaind -daemon
			sleep 5
			if ${CRTDIR}/sugarchain-API-addressindex/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe getconnectioncount > /dev/null 2>&1 ; then
				string_limit_check_mark "The sugar chain API node has been started. Please enter other numbers in 10 seconds to check the node status......" "The sugar chain API node has been started. Please enter other numbers in 10 seconds to check the node status${GREEN}${CYAN} ......"
			fi
			sleep 5
		else
			string_limit_check_mark "The detection API node has been started, there is no need to restart it again........." "The detection API node has been started, there is no need to restart it again${GREEN}${CYAN} ........."
			sleep 5
		fi
	fi
	
	if ! curl http://127.0.0.1:5000/info > /dev/null 2>&1; then
		if [[ ! -d ${CRTDIR}/api-server ]]; then
			git clone https://github.com/sugarchain-project/api-server.git
		fi
		
		if [[ ! -f ${CRTDIR}/api-server/config.py ]]; then
			SECRET=`pwgen -s 12 1`
			cat << EOF >  ${CRTDIR}/api-server/config.py
rid = 'sugar-api'
cache = 3600
secret = "$SECRET"
endpoint = 'http://baihe:passwordbaihe@127.0.0.1:34229/'
host = '0.0.0.0'
port = 1234
debug = False
block_page = 10
tx_page = 25
EOF
		fi
			
		if [[ ! -f /etc/systemd/system/sugar-api.service ]]; then
			cat << EOF >  /etc/systemd/system/sugar-api.service
[Unit]
Description=Gunicorn instance to serve sugar api
After=network.target

[Service]
User=root
Group=www-data
WorkingDirectory=/root/api-server
Environment="PATH=/root/api-server/venv/bin"
ExecStart=/root/api-server/venv/bin/gunicorn app:app --worker-class eventlet -w 1 --bind 0.0.0.0:5000

[Install]
WantedBy=multi-user.target
EOF
		fi
			
		cd api-server/
		if [[ -d ${CRTDIR}/api-server/venv ]]; then
			rm -rf ${CRTDIR}/api-server/venv
		fi
		
		python3.8 -m venv venv
		source venv/bin/activate
		pip3 install -r requirements.txt
		pip3 install webargs
		deactivate
		
		sudo systemctl enable sugar-api.service
		sudo systemctl start sugar-api.service
		
		string_limit_check_mark "Successfully build SugarChain API node......" "Successfully build SugarChain API node${GREEN}${CYAN} ......"
		string_limit_check_mark "http://$ip:5000" "http://$ip:5000${GREEN}${CYAN} ......"

	fi
}

function Stop_sugar_node(){
	cd ~/
	echo -e "${ARROW} ${YELLOW}Start closing SugarChain API node ....${NC}"
	${CRTDIR}/sugarchain-API-addressindex/sugarchain-cli stop
	string_limit_check_mark "Successfully stopped SugarChain API node......" "Successfully stopped SugarChain API node${GREEN}${CYAN} ......"
	sleep 5
}

function API_domain(){
	read -p "input your domain,For example api.example.com: " domain
	
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
        proxy_pass http://localhost:5000;
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
        proxy_pass http://127.0.0.1:5000/socket.io;
    }

    listen 80;
}
EOF
	fi
	
	sudo ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled
	sudo snap install --classic certbot
	sudo certbot --nginx -d $domain
}

function install_step(){

	sudo $* install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev -y

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
	
	sudo $* install pwgen
	
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

CRON_LINE="${CRTDIR}/sugarchain-API-addressindex/sugarchaind -daemon"
CRON_EXISTS=$(crontab -l | grep "$CRON_LINE" | wc -l)
if [ $CRON_EXISTS -eq 0 ]
then
	crontab -l | { cat; echo "*/5 * * * * $CRON_LINE"; } | crontab -
	string_limit_check_mark "Timed start task setting completed........." "Timed start task setting completed.........${GREEN}${CYAN} ........."
else
	string_limit_check_mark "Timed start task already exists........." "Timed start task already exists${GREEN}${CYAN} ........."
fi

if ! curl http://127.0.0.1:5000/info > /dev/null 2>&1; then
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
else
	string_limit_check_mark "SugarChain API Node already exists, no need to build it......" "SugarChain API Node already exists, no need to build it${GREEN}${CYAN} ......"
	string_limit_check_mark "http://$ip:5000" "http://$ip:5000${GREEN}${CYAN} ......"
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
	echo -e "${CYAN}1  - Start SugarChain API Node[Including installation process]${NC}"
	echo -e "${CYAN}2  - Update API node configuration file[Update content based on GitHub file]${NC}"
	echo -e "${CYAN}3  - View the current number of blocks${NC}"
	echo -e "${CYAN}4  - View the number of node connections${NC}"
	echo -e "${CYAN}5  - View version${NC}"
	echo -e "${CYAN}6  - Viewing the download progress of block headers${NC}"
	echo -e "${CYAN}7  - Stop SugarChain API node${NC}"
	echo -e "${CYAN}8  - Set your domain${NC}"
	echo -e "${YELLOW}===========================================================${NC}"
	echo -e "${YELLOW}******SugarChain creation API node script******${NC}"
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
		${CRTDIR}/sugarchain-API-addressindex/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe getblockcount
	 ;;
	 4) 

		sleep 2
		${CRTDIR}/sugarchain-API-addressindex/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe getconnectioncount
	 ;;
	 5) 

		sleep 2
		${CRTDIR}/sugarchain-API-addressindex/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe -version
	 ;;
	 6) 

		sleep 2
		${CRTDIR}/sugarchain-API-addressindex/sugarchain-cli -rpcuser=baihe -rpcpassword=passwordbaihe getblockchaininfo | grep headers
	 ;;
	 7)
		sleep 2
		Stop_sugar_node
	 ;;
	 
	 8)
		sleep 2
		API_domain
	 ;;

		esac

done

