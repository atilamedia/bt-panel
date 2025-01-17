#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8

GetCpuStat(){
        time1=$(cat /proc/stat |grep 'cpu ')
        sleep 1
        time2=$(cat /proc/stat |grep 'cpu ')
        cpuTime1=$(echo ${time1}|awk '{print $2+$3+$4+$5+$6+$7+$8}')
        cpuTime2=$(echo ${time2}|awk '{print $2+$3+$4+$5+$6+$7+$8}')
        runTime=$((${cpuTime2}-${cpuTime1}))
        idelTime1=$(echo ${time1}|awk '{print $5}')
        idelTime2=$(echo ${time2}|awk '{print $5}')
        idelTime=$((${idelTime2}-${idelTime1}))
        useTime=$(((${runTime}-${idelTime})*3))
        [ ${useTime} -gt ${runTime} ] && cpuBusy="true"
        if [ "${cpuBusy}" == "true" ]; then
                cpuCore=$((${cpuInfo}/2))
        else
                cpuCore=$((${cpuInfo}-1))
        fi
}
GetPackManager(){
        if [ -f "/usr/bin/yum" ] && [ -f "/etc/yum.conf" ]; then
                PM="yum"
        elif [ -f "/usr/bin/apt-get" ] && [ -f "/usr/bin/dpkg" ]; then
                PM="apt-get"            
        fi
}
cpuInfo=$(getconf _NPROCESSORS_ONLN)
if [ "${cpuInfo}" -ge "4" ];then
        GetCpuStat
else
        cpuCore="1"
fi
GetPackManager

download_Url='http://128.1.164.196:5880'

tengine='2.3.0'
nginx_108='1.8.1'
nginx_112='1.12.2'
nginx_114='1.14.2'
nginx_115='1.15.10'
nginx_116='1.16.0'
nginx_117='1.17.0'
openresty='1.13.6.2'

Root_Path='/www'
Setup_Path=$Root_Path/server/nginx
run_path='/root'

if [ -z "${cpuCore}" ]; then
	cpuCore="1"
fi

System_Lib(){
	if [ "${PM}" == "yum" ] || [ "${PM}" == "dnf" ] ; then
		Pack="curl curl-devel libtermcap-devel ncurses-devel libevent-devel readline-devel"
		${PM} install ${Pack} -y
	elif [ "${PM}" == "apt-get" ]; then
		Pack="libgd3 libgd-dev libevent-dev libncurses5-dev libreadline-dev"
		${PM} install ${Pack} -y
	fi
}
Service_Add(){
	if [ "${PM}" == "yum" ] || [ "${PM}" == "dnf" ]; then
		chkconfig --add nginx
		chkconfig --level 2345 nginx on
	elif [ "${PM}" == "apt-get" ]; then
		update-rc.d nginx defaults
	fi 
}
Service_Del(){
 	if [ "${PM}" == "yum" ] || [ "${PM}" == "dnf" ]; then
		chkconfig --del nginx
		chkconfig --level 2345 nginx off
	elif [ "${PM}" == "apt-get" ]; then
		update-rc.d nginx remove
	fi
}
Set_Time(){
	BtDate=$(curl https://www.bt.cn//api/index/get_date|awk '{print $1}')
	SysTime=$(date +%Y%m%d)
	if [ "${BtTime}" != "" ];then
		if [ "${SysTime}" != "${BtTime}" ]; then
			date -s "$(curl https://www.bt.cn//api/index/get_date)"
		fi
	fi
}
Install_Configure(){
	if [ -f "/usr/local/lib/libjemalloc.so" ]; then
		jemallocLD="--with-ld-opt="-ljemalloc""
	else
		jemallocLD=""
	fi
	if [ "${version}" == "1.15" ] || [ "${version}" == "1.17" ];then
		./configure --user=www --group=www --prefix=${Setup_Path} --with-openssl=${Setup_Path}/src/openssl --add-module=${Setup_Path}/src/ngx_devel_kit --add-module=${Setup_Path}/src/lua_nginx_module --add-module=${Setup_Path}/src/ngx_cache_purge --add-module=${Setup_Path}/src/nginx-sticky-module --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module --with-http_image_filter_module --with-http_gzip_static_module --with-http_gunzip_module --with-stream --with-stream_ssl_module --with-ipv6 --with-http_sub_module --with-http_flv_module --with-http_addition_module --with-http_realip_module --with-http_mp4_module --with-ld-opt="-Wl,-E" --with-openssl-opt="enable-tls1_3 enable-weak-ssl-ciphers" --with-cc-opt="-Wno-error" ${jemallocLD}
	elif [ "${version}" == "1.14" ] || [ "${version}" == "1.12" ] || [ "${version}" == "1.16" ] || [ "${version}" == "1.10" ]; then
		./configure --user=www --group=www --prefix=${Setup_Path} --with-openssl=${Setup_Path}/src/openssl --add-module=${Setup_Path}/src/ngx_devel_kit --add-module=${Setup_Path}/src/lua_nginx_module --add-module=${Setup_Path}/src/ngx_cache_purge --add-module=${Setup_Path}/src/nginx-sticky-module --add-module=${Setup_Path}/src/nginx-http-concat --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module --with-http_image_filter_module --with-http_gzip_static_module --with-http_gunzip_module --with-stream --with-stream_ssl_module --with-ipv6 --with-http_sub_module --with-http_flv_module --with-http_addition_module --with-http_realip_module --with-http_mp4_module --with-ld-opt="-Wl,-E" --with-pcre=pcre-${pcre_version} --with-cc-opt="-Wno-error" ${jemallocLD}
	elif [ "${version}" == "1.8" ]; then
		./configure --user=www --group=www --prefix=${Setup_Path} --add-module=${Setup_Path}/src/ngx_devel_kit --add-module=${Setup_Path}/src/lua_nginx_module --add-module=${Setup_Path}/src/ngx_cache_purge --add-module=${Setup_Path}/src/nginx-sticky-module --add-module=${Setup_Path}/src/nginx-http-concat --with-http_stub_status_module --with-http_ssl_module --with-http_image_filter_module --with-http_spdy_module --with-http_gzip_static_module --with-http_gunzip_module --with-ipv6 --with-http_sub_module --with-http_flv_module --with-http_addition_module --with-http_realip_module --with-http_mp4_module --with-ld-opt="-Wl,-E" --with-pcre=pcre-${pcre_version} --with-cc-opt="-Wno-error" ${jemallocLD}
	elif [ "${version}" == "tengine" ]; then
		./configure --user=www --group=www --prefix=${Setup_Path} --add-module=${Setup_Path}/src/ngx_devel_kit --with-openssl=${Setup_Path}/src/openssl --add-module=${Setup_Path}/src/ngx_cache_purge --add-module=${Setup_Path}/src/nginx-sticky-module --add-module=${Setup_Path}/src/lua_nginx_module --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module --with-http_image_filter_module --with-http_gzip_static_module --with-http_gunzip_module --with-ipv6 --with-http_sub_module --with-http_flv_module --with-http_addition_module --with-http_realip_module --with-http_mp4_module --with-ld-opt="-Wl,-E" --with-pcre=pcre-${pcre_version} --with-cc-opt="-Wno-error"
	elif [ "${version}" == "openresty" ]; then
		./configure --user=www --group=www --prefix=${Setup_Path} --with-openssl=${Setup_Path}/src/openssl --with-pcre=pcre-${pcre_version} --add-module=${Setup_Path}/src/ngx_cache_purge --add-module=${Setup_Path}/src/nginx-sticky-module --add-module=${Setup_Path}/src/nginx-http-concat --with-luajit --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module --with-http_image_filter_module --with-http_gzip_static_module --with-http_gunzip_module --with-stream --with-stream_ssl_module --with-ipv6 --with-http_sub_module --with-http_flv_module --with-http_addition_module --with-http_realip_module --with-http_mp4_module --with-ld-opt="-Wl,-E" --with-cc-opt="-Wno-error" ${jemallocLD}
	fi
}
Install_Jemalloc(){
	if [ ! -f '/usr/local/lib/libjemalloc.so' ]; then
		wget -O jemalloc-5.0.1.tar.bz2 ${download_Url}/src/jemalloc-5.0.1.tar.bz2
		tar -xvf jemalloc-5.0.1.tar.bz2
		cd jemalloc-5.0.1
		./configure
		make && make install
		ldconfig
		cd ..
		rm -rf jemalloc*
	fi
}
Install_cjson()
{
	if [ ! -f /usr/local/lib/lua/5.1/cjson.so ];then
		wget -O lua-cjson-2.1.0.tar.gz $download_Url/install/src/lua-cjson-2.1.0.tar.gz -T 20
		tar xvf lua-cjson-2.1.0.tar.gz
		rm -f lua-cjson-2.1.0.tar.gz
		cd lua-cjson-2.1.0
		make
		make install
		cd ..
		rm -rf lua-cjson-2.1.0
	fi
}
Install_LuaJIT()
{
	if [ ! -d '/usr/local/include/luajit-2.0' ];then
		wget -c -O LuaJIT-2.0.4.tar.gz ${download_Url}/install/src/LuaJIT-2.0.4.tar.gz -T 5
		tar xvf LuaJIT-2.0.4.tar.gz
		cd LuaJIT-2.0.4
		make linux
		make install
		cd ..
		rm -rf LuaJIT-*
		export LUAJIT_LIB=/usr/local/lib
		export LUAJIT_INC=/usr/local/include/luajit-2.0/
		ln -sf /usr/local/lib/libluajit-5.1.so.2 /usr/local/lib64/libluajit-5.1.so.2
		echo "/usr/local/lib" >> /etc/ld.so.conf
		ldconfig
	fi
}
Nginx_Waf(){
	cat > ${Setup_Path}/conf/luawaf.conf<<EOF
lua_shared_dict limit 10m;
lua_package_path "/www/server/nginx/waf/?.lua";
init_by_lua_file  /www/server/nginx/waf/init.lua;
access_by_lua_file /www/server/nginx/waf/waf.lua;
EOF
	mkdir -p /www/wwwlogs/waf
	chown www.www /www/wwwlogs/waf
	chmod 744 /www/wwwlogs/waf
	mkdir -p /www/server/panel/vhost
	wget -O waf.zip ${download_Url}/install/waf/waf.zip
	unzip -o waf.zip -d $Setup_Path/ > /dev/null
	if [ ! -d "/www/server/panel/vhost/wafconf" ];then
		mv $Setup_Path/waf/wafconf /www/server/panel/vhost/wafconf
	fi
	cd ${Setup_Path}
	rm -f src.tar.gz
	CheckPHPVersion
	sed -i "s/#limit_conn_zone.*/limit_conn_zone \$binary_remote_addr zone=perip:10m;\n\tlimit_conn_zone \$server_name zone=perserver:10m;/" ${Setup_Path}/conf/nginx.conf
	sed -i "s/mime.types;/mime.types;\n\t\tinclude proxy.conf;\n/" ${Setup_Path}/conf/nginx.conf
	#if [ "${nginx_version}" == "1.12.2" ] || [ "${nginx_version}" == "openresty" ] || [ "${nginx_version}" == "1.14.2" ];then
	sed -i "s/mime.types;/mime.types;\n\t\t#include luawaf.conf;\n/" ${Setup_Path}/conf/nginx.conf
	#fi
}
CheckPHPVersion()
{
	PHPVersion=""
	for phpVer in 52 53 54 55 56 70 71 72 73;
	do
		if [ -d "/www/server/php/${phpVer}/bin" ]; then
			PHPVersion=${phpVer}
		fi
	done

	if [ "${PHPVersion}" != '' ];then
		\cp -r -a ${Setup_Path}/conf/enable-php-${PHPVersion}.conf ${Setup_Path}/conf/enable-php.conf
	fi
}

Download_Src(){
	TLSv13_NGINX=$(echo ${nginxVersion}|tr -d '.'|cut -c 1-3)
	if [ "${TLSv13_NGINX}" -ge "115" ];then
		opensslVer="1.1.1b"
	else
		opensslVer="1.0.2r"
	fi
	wget -O openssl.tar.gz ${download_Url}/src/openssl-${opensslVer}.tar.gz -T 5
	tar -xvf openssl.tar.gz
	mv openssl-${opensslVer} openssl
	rm -f openssl.tar.gz

	pcre_version=8.42
    wget -O pcre-$pcre_version.tar.gz ${download_Url}/src/pcre-$pcre_version.tar.gz -T 5
	tar zxf pcre-$pcre_version.tar.gz

	wget -O ngx_cache_purge.tar.gz ${download_Url}/src/ngx_cache_purge-2.3.tar.gz
	tar -zxvf ngx_cache_purge.tar.gz
	mv ngx_cache_purge-2.3 ngx_cache_purge
	rm -f ngx_cache_purge.tar.gz

	wget -O nginx-sticky-module.zip ${download_Url}/src/nginx-sticky-module.zip
	unzip nginx-sticky-module.zip
	rm -f nginx-sticky-module.zip

	wget -O nginx-http-concat.zip ${download_Url}/src/nginx-http-concat-1.2.2.zip
	unzip nginx-http-concat.zip
	mv nginx-http-concat-1.2.2 nginx-http-concat
	rm -f nginx-http-concat.zip

	#lua_nginx_module
	LuaModVer="0.10.13"
	wget -c -O lua-nginx-module-${LuaModVer}.zip ${download_Url}/src/lua-nginx-module-${LuaModVer}.zip -T 5
	unzip lua-nginx-module-${LuaModVer}.zip
	mv lua-nginx-module-${LuaModVer} lua_nginx_module
	rm -f lua-nginx-module-${LuaModVer}.zip
	
	#ngx_devel_kit
	NgxDevelKitVer="0.3.1rc1"
	wget -c -O ngx_devel_kit-${NgxDevelKitVer}.zip ${download_Url}/src/ngx_devel_kit-${NgxDevelKitVer}.zip -T 5
	unzip ngx_devel_kit-${NgxDevelKitVer}.zip
	mv ngx_devel_kit-${NgxDevelKitVer} ngx_devel_kit
	rm -f ngx_devel_kit-${NgxDevelKitVer}.zip	
}

Install_Nginx(){
	if [ "${actionType}" == "install" ];then
		Uninstall_Nginx
		System_Lib
		Run_User="www"
		wwwUser=$(cat /etc/passwd|grep www)
		if [ "${wwwUser}" == "" ];then
			groupadd ${Run_User}
			useradd -s /sbin/nologin -g ${Run_User} ${Run_User}
		fi
		mkdir -p ${Setup_Path}
		rm -rf ${Setup_Path}/*
	fi
	cd ${Setup_Path}
	rm -rf ${Setup_Path}/src

	if [ "${version}" == "tengine" ] || [ "${version}" == "openresty" ]; then
		wget -O ${Setup_Path}/src.tar.gz ${download_Url}/src/${version}-${nginxVersion}.tar.gz -T20
		tar -xvf src.tar.gz
		mv ${version}-${nginxVersion} src
	else
		wget -O ${Setup_Path}/src.tar.gz ${download_Url}/src/nginx-${nginxVersion}.tar.gz -T20
		tar -xvf src.tar.gz
		tar -xvf src.tar.gz
		mv nginx-${nginxVersion} src
	fi
	rm -f src.tar.gz
	cd src
	
	export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH 

	Set_Time
	Download_Src
	Install_Jemalloc
	Install_LuaJIT
	Install_cjson

	if [ -f  "/www/server/panel/install/configure.pl" ]; then
		Configure=$(cat /www/server/panel/install/configure.pl)
		./configure ${Configure}
	else
		Install_Configure	
	fi

	make -j${cpuCore}

	if [ "${actionType}" == "update" ]; then
		if [ "${nginxVersion}" = "openresty" ]; then
			make install
			echo -e "done"
			nginx -v
			echo "${nginxVersion}" > ${Setup_Path}/version.pl
			rm -f ${Setup_Path}/version_check.pl
			exit;
		fi
		if [ ! -f ${Setup_Path}/src/objs/nginx ]; then
			exit;
		fi
		sleep 1
		/etc/init.d/nginx stop
		mv -f ${Setup_Path}/sbin/nginx ${Setup_Path}/sbin/nginxBak
		\cp -rfp ${Setup_Path}/src/objs/nginx ${Setup_Path}/sbin/
		sleep 1
		/etc/init.d/nginx start
		rm -rf ${Setup_Path}/src
		nginx -v
		echo "${nginxVersion}" > ${Setup_Path}/version.pl
		rm -f ${Setup_Path}/version_check.pl
		if [ "${version}" == "tengine" ]; then
			echo "2.2.4(2.3.0)" > ${Setup_Path}/version_check.pl
		fi
		exit
	fi

	make install

	cd ..

	if [ "${version}" == "openresty" ];then
		ln -sf /www/server/nginx/nginx/html /www/server/nginx/html
		ln -sf /www/server/nginx/nginx/conf /www/server/nginx/conf
		ln -sf /www/server/nginx/nginx/logs /www/server/nginx/logs
		ln -sf /www/server/nginx/nginx/sbin /www/server/nginx/sbin
	fi

	if [ ! -f "${Setup_Path}/sbin/nginx" ];then
		echo '========================================================'
		echo -e "\033[31mERROR: nginx-${nginxVersion} installation failed.\033[0m";
		echo -e "\033[31m安装失败，请截图以上报错信息发帖至论坛www.bt.cn/bbs求助\033[0m"
		rm -rf ${Setup_Path}
		exit 0;
	fi

	ln -sf ${Setup_Path}/sbin/nginx /usr/bin/nginx
	rm -f ${Setup_Path}/conf/nginx.conf

	Default_Website_Dir=$Root_Path'/wwwroot/default'
	mkdir -p ${Default_Website_Dir}
	mkdir -p ${Root_Path}/wwwlogs
	mkdir -p ${Setup_Path}/conf/vhost
	mkdir -p /usr/local/nginx/logs
	mkdir -p ${Setup_Path}/conf/rewrite

	wget -O ${Setup_Path}/conf/nginx.conf ${download_Url}/conf/nginx.conf -T20
	wget -O ${Setup_Path}/conf/pathinfo.conf ${download_Url}/conf/pathinfo.conf -T20
	wget -O ${Setup_Path}/conf/enable-php.conf ${download_Url}/conf/enable-php.conf -T20
	wget -O ${Setup_Path}/html/index.html ${download_Url}/error/index.html -T 5

	cat > ${Root_Path}/server/panel/vhost/nginx/phpfpm_status.conf<<EOF
server {
	listen 80;
	server_name 127.0.0.1;
	allow 127.0.0.1;
	location /nginx_status {
		stub_status on;
		access_log off;
	}
EOF
 	echo > /www/server/nginx/conf/enable-php-00.conf
	for phpV in 52 53 54 55 56 70 71 72 73 74 75
	do
	cat > ${Setup_Path}/conf/enable-php-${phpV}.conf<<EOF
	location ~ [^/]\.php(/|$)
	{
		try_files \$uri =404;
		fastcgi_pass  unix:/tmp/php-cgi-${phpV}.sock;
		fastcgi_index index.php;
		include fastcgi.conf;
		include pathinfo.conf;
	}
EOF
	cat >> ${Root_Path}/server/panel/vhost/nginx/phpfpm_status.conf<<EOF
	location /phpfpm_${phpV}_status {
		fastcgi_pass unix:/tmp/php-cgi-${phpV}.sock;
		include fastcgi_params;
		fastcgi_param SCRIPT_FILENAME \$fastcgi_script_name;
	}
EOF
	done
	echo \} >> ${Root_Path}/server/panel/vhost/nginx/phpfpm_status.conf
	cat > ${Setup_Path}/conf/proxy.conf<<EOF
proxy_temp_path ${Setup_Path}/proxy_temp_dir;
proxy_cache_path ${Setup_Path}/proxy_cache_dir levels=1:2 keys_zone=cache_one:20m inactive=1d max_size=5g;
client_body_buffer_size 512k;
proxy_connect_timeout 60;
proxy_read_timeout 60;
proxy_send_timeout 60;
proxy_buffer_size 32k;
proxy_buffers 4 64k;
proxy_busy_buffers_size 128k;
proxy_temp_file_write_size 128k;
proxy_next_upstream error timeout invalid_header http_500 http_503 http_404;
proxy_cache cache_one;
EOF
	sed -i "s#include vhost/\*.conf;#include /www/server/panel/vhost/nginx/\*.conf;#" ${Setup_Path}/conf/nginx.conf
	sed -i "s#/www/wwwroot/default#/www/server/phpmyadmin#" ${Setup_Path}/conf/nginx.conf
	sed -i "/pathinfo/d" ${Setup_Path}/conf/enable-php.conf

	Nginx_Waf
	CheckPHPVersion

	wget -O /etc/init.d/nginx ${download_Url}/init/nginx.init -T 5
	chmod +x /etc/init.d/nginx
	Service_Add
 	/etc/init.d/nginx start

 	if [ "${version}" == "tengine" ]; then
 		echo "-Tengine2.2.3" > ${Setup_Path}/version.pl
 		echo "2.2.4(2.3.0)" > ${Setup_Path}/version_check.pl
 	elif [ "${version}" == "openresty" ]; then
 		echo "openresty" > ${Setup_Path}/version.pl
 	else
 		echo "${nginxVersion}" > ${Setup_Path}/version.pl
 	fi
}
Uninstall_Nginx()
{
	if [ -f "/etc/init.d/nginx" ];then
		Service_Del
		/etc/init.d/nginx stop
		rm -f /etc/init.d/nginx
	fi
	[ -f "${Setup_Path}/rpm.pl" ] && yum remove bt-$(cat ${Setup_Path}/rpm.pl) -y
	pkill -9 nginx
	rm -rf ${Setup_Path}
}

actionType=$1
version=$2

if [ "${actionType}" == "uninstall" ]; then
	Uninstall_Nginx
elif [ "${actionType}" == "install" ] || [ "${actionType}" == "update" ] ; then
	nginxVersion=${tengine}
	if [ "${version}" == "1.10" ] || [ "${version}" == "1.12" ]; then
		nginxVersion=${nginx_112}
	elif [ "${version}" == "1.14" ]; then
		nginxVersion=${nginx_114}
	elif [ "${version}" == "1.15" ]; then
		nginxVersion=${nginx_115}
	elif [ "${version}" == "1.16" ]; then
		nginxVersion=${nginx_116}
	elif [ "${version}" == "1.17" ]; then
		nginxVersion=${nginx_117}
	elif [ "${version}" == "1.8" ]; then
		nginxVersion=${nginx_108}
	elif [ "${version}" == "openresty" ]; then
		nginxVersion=${openresty}
	else
		version="tengine"
	fi
	Install_Nginx
fi
