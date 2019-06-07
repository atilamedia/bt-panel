#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

if [ -f "/usr/bin/apt-get" ];then
	isDebian=`cat /etc/issue|grep Debian`
	if [ "$isDebian" != "" ];then
		apt install wget -y && wget -O install.sh https://raw.githubusercontent.com/atilamedia/bt-panel/master/install/install-ubuntu.sh && bash install.sh
		exit;
	else
		apt install wget -y && wget -O install.sh https://raw.githubusercontent.com/atilamedia/bt-panel/master/install/install-ubuntu.sh && sudo bash install.sh
		exit;
	fi
else 
	yum install wget -y && wget -O install.sh https://raw.githubusercontent.com/atilamedia/bt-panel/master/install/install-centos.sh && sudo bash install.sh
	exit;
fi
