#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
public_file=/www/server/panel/install/public.sh
if [ ! -f $public_file ];then
	wget -O $public_file http://download.bt.cn/install/public.sh -T 5;
fi
. $public_file

download_Url=$NODE_URL

Root_Path=`cat /var/bt_setupPath.conf`
Setup_Path=$Root_Path/server/mysql
Data_Path=$Root_Path/server/data
Is_64bit=`getconf LONG_BIT`
run_path='/root'
mysql_51='5.1.73'
mysql_55='5.5.62'
mysql_56='5.6.44'
mysql_57='5.7.26'
mysql_80='8.0.16'
mariadb_55='5.5.55'
mariadb_100='10.0.38'
mariadb_101='10.1.39'
mariadb_102='10.2.23'
mariadb_103='10.3.14'
alisql_version='5.6.32'

#检测hosts文件
hostfile=`cat /etc/hosts | grep 127.0.0.1 | grep localhost`
if [ "${hostfile}" = '' ]; then
	echo "127.0.0.1  localhost  localhost.localdomain" >> /etc/hosts
fi
gccVersionCheck(){
	gccV=$(gcc -dumpversion|grep ^[78])
	if [ "${gccV}" != "" ]; then
		sed -i "s/field_names\[i\]\[num_fields\*2\].*/field_names\[i\]\[num_fields\*2\]= NULL;/" client/mysql.cc
	fi
}
#删除软链
DelLink()
{	
	rm -f /usr/bin/mysql*
	rm -f /usr/lib/libmysql*
	rm -f /usr/lib64/libmysql*
}

cpuInfo=$(getconf _NPROCESSORS_ONLN)
if [ "${cpuInfo}" -ge "4" ];then
	cpuCore=$((${cpuInfo}-1))
else
	cpuCore="1"
fi

#设置软件链
SetLink()
{
    ln -sf ${Setup_Path}/bin/mysql /usr/bin/mysql
    ln -sf ${Setup_Path}/bin/mysqldump /usr/bin/mysqldump
    ln -sf ${Setup_Path}/bin/myisamchk /usr/bin/myisamchk
    ln -sf ${Setup_Path}/bin/mysqld_safe /usr/bin/mysqld_safe
    ln -sf ${Setup_Path}/bin/mysqlcheck /usr/bin/mysqlcheck
	ln -sf ${Setup_Path}/bin/mysql_config /usr/bin/mysql_config
	
	rm -f /usr/lib/libmysqlclient.so.16
	rm -f /usr/lib64/libmysqlclient.so.16
	rm -f /usr/lib/libmysqlclient.so.18
	rm -f /usr/lib64/libmysqlclient.so.18
	rm -f /usr/lib/libmysqlclient.so.20
	rm -f /usr/lib64/libmysqlclient.so.20
	rm -f /usr/lib/libmysqlclient.so.21
	rm -f /usr/lib64/libmysqlclient.so.21
	
	if [ -f "${Setup_Path}/lib/libmysqlclient.so.18" ];then
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.16
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.16
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.18
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.18
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.20
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.20
	elif [ -f "${Setup_Path}/lib/mysql/libmysqlclient.so.18" ];then
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.16
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.16
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.18
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.18
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.18 /usr/lib/libmysqlclient.so.20
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.18 /usr/lib64/libmysqlclient.so.20
	elif [ -f "${Setup_Path}/lib/libmysqlclient.so.16" ];then
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.16 /usr/lib/libmysqlclient.so.16
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.16 /usr/lib64/libmysqlclient.so.16
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.16 /usr/lib/libmysqlclient.so.18
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.16 /usr/lib64/libmysqlclient.so.18
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.16 /usr/lib/libmysqlclient.so.20
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.16 /usr/lib64/libmysqlclient.so.20
	elif [ -f "${Setup_Path}/lib/mysql/libmysqlclient.so.16" ];then
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.16 /usr/lib/libmysqlclient.so.16
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.16 /usr/lib64/libmysqlclient.so.16
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.16 /usr/lib/libmysqlclient.so.18
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.16 /usr/lib64/libmysqlclient.so.18
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.16 /usr/lib/libmysqlclient.so.20
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.16 /usr/lib64/libmysqlclient.so.20
	elif [ -f "${Setup_Path}/lib/libmysqlclient_r.so.16" ];then
		ln -sf ${Setup_Path}/lib/libmysqlclient_r.so.16 /usr/lib/libmysqlclient_r.so.16
		ln -sf ${Setup_Path}/lib/libmysqlclient_r.so.16 /usr/lib64/libmysqlclient_r.so.16
	elif [ -f "${Setup_Path}/lib/mysql/libmysqlclient_r.so.16" ];then
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient_r.so.16 /usr/lib/libmysqlclient_r.so.16
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient_r.so.16 /usr/lib64/libmysqlclient_r.so.16
	elif [ -f "${Setup_Path}/lib/libmysqlclient.so.20" ];then
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.20 /usr/lib/libmysqlclient.so.16
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.20 /usr/lib64/libmysqlclient.so.16
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.20 /usr/lib/libmysqlclient.so.18
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.20 /usr/lib64/libmysqlclient.so.18
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.20 /usr/lib/libmysqlclient.so.20
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.20 /usr/lib64/libmysqlclient.so.20
	elif [ -f "${Setup_Path}/lib/libmysqlclient.so.21" ];then
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.21 /usr/lib/libmysqlclient.so.16
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.21 /usr/lib64/libmysqlclient.so.16
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.21 /usr/lib/libmysqlclient.so.18
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.21 /usr/lib64/libmysqlclient.so.18
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.21 /usr/lib/libmysqlclient.so.20
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.21 /usr/lib64/libmysqlclient.so.20
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.21 /usr/lib/libmysqlclient.so.21
		ln -sf ${Setup_Path}/lib/libmysqlclient.so.21 /usr/lib64/libmysqlclient.so.21
	elif [ -f "${Setup_Path}/lib/libmariadb.so.3" ]; then
		ln -sf ${Setup_Path}/lib/libmariadb.so.3 /usr/lib/libmysqlclient.so.16
		ln -sf ${Setup_Path}/lib/libmariadb.so.3 /usr/lib64/libmysqlclient.so.16
		ln -sf ${Setup_Path}/lib/libmariadb.so.3 /usr/lib/libmysqlclient.so.18
		ln -sf ${Setup_Path}/lib/libmariadb.so.3 /usr/lib64/libmysqlclient.so.18
		ln -sf ${Setup_Path}/lib/libmariadb.so.3 /usr/lib/libmysqlclient.so.20
		ln -sf ${Setup_Path}/lib/libmariadb.so.3 /usr/lib64/libmysqlclient.so.20
		ln -sf ${Setup_Path}/lib/libmariadb.so.3 /usr/lib/libmysqlclient.so.21
		ln -sf ${Setup_Path}/lib/libmariadb.so.3 /usr/lib64/libmysqlclient.so.21
	elif [ -f "${Setup_Path}/lib/mysql/libmysqlclient.so.20" ];then
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.20 /usr/lib/libmysqlclient.so.16
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.20 /usr/lib64/libmysqlclient.so.16
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.20 /usr/lib/libmysqlclient.so.18
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.20 /usr/lib64/libmysqlclient.so.18
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.20 /usr/lib/libmysqlclient.so.20
		ln -sf ${Setup_Path}/lib/mysql/libmysqlclient.so.20 /usr/lib64/libmysqlclient.so.20
	fi
}

Install_MySQL_51(){
	Close_MySQL
	cd ${run_path}
	#准备安装
	mkdir -p ${Setup_Path}
	rm -rf ${Setup_Path}/*
	cd ${Setup_Path}
	if [ ! -f "${Setup_Path}/src.tar.gz" ];then
		wget -O ${Setup_Path}/src.tar.gz ${download_Url}/src/mysql-$mysql_51.tar.gz -T20
	fi
	tar -zxvf src.tar.gz
	mv mysql-$mysql_51 src
	cd src
	gccVersionCheck
	#编译
	
	./configure --prefix=${Setup_Path} --sysconfdir=/etc --with-plugins=csv,myisam,myisammrg,heap,innobase --with-extra-charsets=all --with-charset=utf8 --with-collation=utf8_general_ci --with-embedded-server --enable-local-infile --enable-assembler --with-mysqld-ldflags=-all-static --enable-thread-safe-client --with-big-tables --with-readline --with-ssl
	make -j${cpuCore}
	make install

	#创建用户
	groupadd mysql
	useradd -s /sbin/nologin -M -g mysql mysql

	#写出配置文件
		cat > /etc/my.cnf<<EOF
[client]
#password	= your_password
port		= 3306
socket		= /tmp/mysql.sock

[mysqld]
port		= 3306
socket		= /tmp/mysql.sock
datadir = ${Data_Path}
default_storage_engine = MyISAM
#skip-external-locking
#loose-skip-innodb
key_buffer_size = 8M
max_allowed_packet = 100G
table_open_cache = 32
sort_buffer_size = 256K
net_buffer_length = 4K
read_buffer_size = 128K
read_rnd_buffer_size = 256K
myisam_sort_buffer_size = 4M
thread_cache_size = 4
query_cache_size = 4M
tmp_table_size = 8M

#skip-networking
#skip-name-resolve
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535

log-bin=mysql-bin
binlog_format=mixed
server-id	= 1
expire_logs_days = 10
slow_query_log=1
slow-query-log-file=${Data_Path}/mysql-slow.log
long_query_time=3
#log_queries_not_using_indexes=on

innodb_data_home_dir = ${Data_Path}
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = ${Data_Path}
innodb_buffer_pool_size = 16M
innodb_additional_mem_pool_size = 2M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF

	MySQL_Opt
	#处理数据目录
	if [ -d "${Data_Path}" ]; then
		rm -rf ${Data_Path}/*
		else
			mkdir -p ${Data_Path}
		fi
		chown -R mysql:mysql ${Data_Path}
		${Setup_Path}/bin/mysql_install_db --defaults-file=/etc/my.cnf --basedir=${Setup_Path} --datadir=${Data_Path} --user=mysql
		chgrp -R mysql ${Setup_Path}/.
		\cp support-files/mysql.server /etc/init.d/mysqld
		chmod 755 /etc/init.d/mysqld
		sed -i "s#\"\$\*\"#--sql-mode=\"NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\"#" /etc/init.d/mysqld
		sed -i '/case "$mode" in/i\ulimit -s unlimited' /etc/init.d/mysqld
		cat > /etc/ld.so.conf.d/mysql.conf<<EOF
${Setup_Path}/lib
/usr/local/lib
EOF

	

	#启动服务
    ldconfig
	#chown mysql:mysql /etc/my.cnf
    ln -sf ${Setup_Path}/lib/mysql /usr/lib/mysql
    ln -sf ${Setup_Path}/include/mysql /usr/include/mysql
	/etc/init.d/mysqld start
	
	#设置软链
    SetLink
	ldconfig

	#设置密码
    ${Setup_Path}/bin/mysqladmin -u root password "${mysqlpwd}"
	
	#添加到服务列表
    update-rc.d mysqld defaults
	
	cd ${Setup_Path}
	rm -f src.tar.gz
	rm -rf src
	echo "${mysql_51}" > ${Setup_Path}/version.pl
	
	
}

Install_MySQL_55(){
	Close_MySQL
	cd ${run_path}
	#准备安装
	mkdir -p ${Setup_Path}
	rm -rf ${Setup_Path}/*
	cd ${Setup_Path}
	if [ ! -f "${Setup_Path}/src.tar.gz" ];then
		wget -O ${Setup_Path}/src.tar.gz ${download_Url}/src/mysql-$mysql_55.tar.gz -T20
	fi
	tar -zxvf src.tar.gz
	mv mysql-$mysql_55 src
	cd src
	gccVersionCheck
	#编译
	
	cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
	make -j${cpuCore}
	make install

	if [ ! -f "${Setup_Path}/bin/mysqld" ];then
		echo '========================================================'
		echo -e "\033[31mERROR: mysql-5.5 installation failed.\033[0m";
		rm -rf ${Setup_Path}
		exit 0;
	fi
	
	#创建用户
	groupadd mysql
	useradd -s /sbin/nologin -M -g mysql mysql

	#写出配置文件
		cat > /etc/my.cnf<<EOF
[client]
#password	= your_password
port		= 3306
socket		= /tmp/mysql.sock

[mysqld]
port		= 3306
socket		= /tmp/mysql.sock
datadir = ${Data_Path}
default_storage_engine = MyISAM
#skip-external-locking
#loose-skip-innodb
key_buffer_size = 8M
max_allowed_packet = 100G
table_open_cache = 32
sort_buffer_size = 256K
net_buffer_length = 4K
read_buffer_size = 128K
read_rnd_buffer_size = 256K
myisam_sort_buffer_size = 4M
thread_cache_size = 4
query_cache_size = 4M
tmp_table_size = 8M

#skip-networking
#skip-name-resolve
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535

log-bin=mysql-bin
binlog_format=mixed
server-id	= 1
expire_logs_days = 10
slow_query_log=1
slow-query-log-file=${Data_Path}/mysql-slow.log
long_query_time=3
#log_queries_not_using_indexes=on

default_storage_engine = InnoDB
innodb_data_home_dir = ${Data_Path}
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = ${Data_Path}
innodb_buffer_pool_size = 16M
innodb_additional_mem_pool_size = 2M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 120
innodb_max_dirty_pages_pct = 90
innodb_read_io_threads = 4
innodb_write_io_threads = 4

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF

	MySQL_Opt
	#处理数据目录
	if [ -d "${Data_Path}" ]; then
		rm -rf ${Data_Path}/*
		else
			mkdir -p ${Data_Path}
		fi
		chown -R mysql:mysql ${Data_Path}
		${Setup_Path}/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=${Setup_Path} --datadir=${Data_Path} --user=mysql
		chgrp -R mysql ${Setup_Path}/.
		\cp support-files/mysql.server /etc/init.d/mysqld
		chmod 755 /etc/init.d/mysqld
		sed -i "s#\"\$\*\"#--sql-mode=\"NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\"#" /etc/init.d/mysqld
		sed -i '/case "$mode" in/i\ulimit -s unlimited' /etc/init.d/mysqld
		cat > /etc/ld.so.conf.d/mysql.conf<<EOF
${Setup_Path}/lib
/usr/local/lib
EOF

	

	#启动服务
    ldconfig
	#chown mysql:mysql /etc/my.cnf
    ln -sf ${Setup_Path}/lib/mysql /usr/lib/mysql
    ln -sf ${Setup_Path}/include/mysql /usr/include/mysql
	/etc/init.d/mysqld start
	
	#设置软链
    SetLink
	ldconfig

	#设置密码
    ${Setup_Path}/bin/mysqladmin -u root password "${mysqlpwd}"
	
	#添加到服务列表
    update-rc.d mysqld defaults
	
	cd ${Setup_Path}
	rm -f src.tar.gz
	rm -rf src
	echo "${mysql_55}" > ${Setup_Path}/version.pl
	
	
}

Install_MySQL_56()
{
	Close_MySQL
	cd ${run_path}
	#准备安装
	
	
	mkdir -p ${Setup_Path}
	rm -rf ${Setup_Path}/*
	cd ${Setup_Path}
	if [ ! -f "${Setup_Path}/src.tar.gz" ];then
		wget -O ${Setup_Path}/src.tar.gz ${download_Url}/src/mysql-$mysql_56.tar.gz -T20
	fi
	tar -zxvf src.tar.gz
	mv mysql-$mysql_56 src
	cd src
	
    
    cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
    make -j${cpuCore}
    make install
	
	if [ ! -f "${Setup_Path}/bin/mysqld" ];then
		echo '========================================================'
		echo -e "\033[31mERROR: mysql-5.6 installation failed.\033[0m";
		rm -rf ${Setup_Path}
		exit 0;
	fi
	
    groupadd mysql
    useradd -s /sbin/nologin -M -g mysql mysql

    cat > /etc/my.cnf<<EOF
[client]
#password   = your_password
port        = 3306
socket      = /tmp/mysql.sock

[mysqld]
port        = 3306
socket      = /tmp/mysql.sock
datadir = ${Data_Path}
skip-external-locking
performance_schema_max_table_instances=400
table_definition_cache=400
key_buffer_size = 8M
max_allowed_packet = 100G
table_open_cache = 32
sort_buffer_size = 256K
net_buffer_length = 8K
read_buffer_size = 128K
read_rnd_buffer_size = 256K
myisam_sort_buffer_size = 4M
thread_cache_size = 4
query_cache_size = 4M
tmp_table_size = 8M
sql-mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

explicit_defaults_for_timestamp = true
#skip-networking
#skip-name-resolve
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535
sql-mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTIO

log-bin=mysql-bin
binlog_format=mixed
server-id   = 1
expire_logs_days = 10
slow_query_log=1
slow-query-log-file=${Data_Path}/mysql-slow.log
long_query_time=3
#log_queries_not_using_indexes=on

#loose-innodb-trx=0
#loose-innodb-locks=0
#loose-innodb-lock-waits=0
#loose-innodb-cmp=0
#loose-innodb-cmp-per-index=0
#loose-innodb-cmp-per-index-reset=0
#loose-innodb-cmp-reset=0
#loose-innodb-cmpmem=0
#loose-innodb-cmpmem-reset=0
#loose-innodb-buffer-page=0
#loose-innodb-buffer-page-lru=0
#loose-innodb-buffer-pool-stats=0
#loose-innodb-metrics=0
#loose-innodb-ft-default-stopword=0
#loose-innodb-ft-inserted=0
#loose-innodb-ft-deleted=0
#loose-innodb-ft-being-deleted=0
#loose-innodb-ft-config=0
#loose-innodb-ft-index-cache=0
#loose-innodb-ft-index-table=0
#loose-innodb-sys-tables=0
#loose-innodb-sys-tablestats=0
#loose-innodb-sys-indexes=0
#loose-innodb-sys-columns=0
#loose-innodb-sys-fields=0
#loose-innodb-sys-foreign=0
#loose-innodb-sys-foreign-cols=0

default_storage_engine = InnoDB
innodb_data_home_dir = ${Data_Path}
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = ${Data_Path}
innodb_buffer_pool_size = 16M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 120
innodb_max_dirty_pages_pct = 90
innodb_read_io_threads = 4
innodb_write_io_threads = 4

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF
    
    MySQL_Opt
    if [ -d "${Data_Path}" ]; then
        rm -rf ${Data_Path}/*
    else
        mkdir -p ${Data_Path}
    fi
    #chown -R mysql:mysql ${Data_Path}
    ${Setup_Path}/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=${Setup_Path} --datadir=${Data_Path} --user=mysql
    chgrp -R mysql ${Setup_Path}/.
    \cp support-files/mysql.server /etc/init.d/mysqld
    chmod 755 /etc/init.d/mysqld
	sed -i "s#\"\$\*\"#--sql-mode=\"NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\"#" /etc/init.d/mysqld
	sed -i '/case "$mode" in/i\ulimit -s unlimited' /etc/init.d/mysqld
    cat > /etc/ld.so.conf.d/mysql.conf<<EOF
    ${Setup_Path}/lib
    /usr/local/lib
EOF
	
	
	#启动服务
    ldconfig
	chown mysql:mysql /etc/my.cnf
    ln -sf ${Setup_Path}/lib/mysql /usr/lib/mysql
    ln -sf ${Setup_Path}/include/mysql /usr/include/mysql
	/etc/init.d/mysqld start
	
	#设置软链
    SetLink
	ldconfig
	
	
	#设置密码
    ${Setup_Path}/bin/mysqladmin -u root password "${mysqlpwd}"
	
	#添加到服务列表
    update-rc.d mysqld defaults
	
	cd ${Setup_Path}
	rm -f src.tar.gz
	rm -rf src
	echo "${mysql_56}" > ${Setup_Path}/version.pl
	

}


Install_MySQL_57()
{
	Close_MySQL
	cd ${run_path}
	#准备安装
	Setup_Path="/www/server/mysql"
	Data_Path="/www/server/data"
	if [ ! -f "/usr/local/lib/libboost_wave.so.1.59.0" ];then
		if [ ! -f "boost_1_59_0.tar.gz" ];then
			wget ${download_Url}/src/boost_1_59_0.tar.gz -T20
		fi
		tar -zxvf boost_1_59_0.tar.gz
		cd boost_1_59_0
		
	    ./bootstrap.sh
	    ./b2
	    ./b2 install
		
		cd ..
	    rm -rf boost_1_59_0
		rm -f boost_1_59_0.tar.gz
    fi
	
	mkdir -p ${Setup_Path}
	rm -rf ${Setup_Path}/*
	cd ${Setup_Path}
	if [ ! -f "${Setup_Path}/src.tar.gz" ];then
		wget -O ${Setup_Path}/src.tar.gz  ${download_Url}/src/mysql-$mysql_57.tar.gz -T20
	fi
	tar -zxvf src.tar.gz
	mv mysql-$mysql_57 src
	cd src
	
    cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
    make -j${cpuCore}
    make install

    groupadd mysql
    useradd -s /sbin/nologin -M -g mysql mysql

    cat > /etc/my.cnf<<EOF
[client]
#password   = your_password
port        = 3306
socket      = /tmp/mysql.sock

[mysqld]
port        = 3306
socket      = /tmp/mysql.sock
datadir = ${Data_Path}
skip-external-locking
performance_schema_max_table_instances=400
table_definition_cache=400
key_buffer_size = 16M
max_allowed_packet = 100G
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
query_cache_size = 8M
tmp_table_size = 16M
sql-mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

explicit_defaults_for_timestamp = true
#skip-networking
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535

log-bin=mysql-bin
binlog_format=mixed
server-id   = 1
expire_logs_days = 10
slow_query_log=1
slow-query-log-file=${Data_Path}/mysql-slow.log
long_query_time=3
#log_queries_not_using_indexes=on
early-plugin-load = ""

#loose-innodb-trx=0
#loose-innodb-locks=0
#loose-innodb-lock-waits=0
#loose-innodb-cmp=0
#loose-innodb-cmp-per-index=0
#loose-innodb-cmp-per-index-reset=0
#loose-innodb-cmp-reset=0
#loose-innodb-cmpmem=0
#loose-innodb-cmpmem-reset=0
#loose-innodb-buffer-page=0
#loose-innodb-buffer-page-lru=0
#loose-innodb-buffer-pool-stats=0
#loose-innodb-metrics=0
#loose-innodb-ft-default-stopword=0
#loose-innodb-ft-inserted=0
#loose-innodb-ft-deleted=0
#loose-innodb-ft-being-deleted=0
#loose-innodb-ft-config=0
#loose-innodb-ft-index-cache=0
#loose-innodb-ft-index-table=0
#loose-innodb-sys-tables=0
#loose-innodb-sys-tablestats=0
#loose-innodb-sys-indexes=0
#loose-innodb-sys-columns=0
#loose-innodb-sys-fields=0
#loose-innodb-sys-foreign=0
#loose-innodb-sys-foreign-cols=0

default_storage_engine = InnoDB
innodb_data_home_dir = ${Data_Path}
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = ${Data_Path}
innodb_buffer_pool_size = 16M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 120
innodb_max_dirty_pages_pct = 90
innodb_read_io_threads = 4
innodb_write_io_threads = 4

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF

    MySQL_Opt
    if [ -d "${Data_Path}" ]; then
        rm -rf ${Data_Path}/*
    else
        mkdir -p ${Data_Path}
    fi
    chown -R mysql:mysql ${Data_Path}
    ${Setup_Path}/bin/mysqld --initialize-insecure --basedir=${Setup_Path} --datadir=${Data_Path} --user=mysql
    chgrp -R mysql ${Setup_Path}/.
    \cp support-files/mysql.server /etc/init.d/mysqld
    chmod 755 /etc/init.d/mysqld
    sed -i '/case "$mode" in/i\ulimit -s unlimited' /etc/init.d/mysqld
    cat > /etc/ld.so.conf.d/mysql.conf<<EOF
    ${Setup_Path}/lib
    /usr/local/lib
EOF


	#启动服务
    ldconfig
    ln -sf ${Setup_Path}/lib/mysql /usr/lib/mysql
    ln -sf ${Setup_Path}/include/mysql /usr/include/mysql
	/etc/init.d/mysqld start
	
	#设置软链
    SetLink
	ldconfig
	
	#设置密码
    ${Setup_Path}/bin/mysqladmin -u root password "${mysqlpwd}"
		
	#添加到服务列表
    update-rc.d mysqld defaults
	
	cd ${Setup_Path}
	rm -f src.tar.gz
	rm -rf src
	echo "${mysql_57}" > ${Setup_Path}/version.pl
	if [ ! -f "${Setup_Path}/bin/mysqld" ];then
		echo '========================================================'
		echo -e "\033[31mERROR: mysql-5.7 installation failed.\033[0m";
		rm -rf ${Setup_Path}
		exit 0;
	fi
}

Install_MySQL_80(){
	Close_MySQL
	cd ${run_path}
	#准备安装
	Setup_Path="/www/server/mysql"
	Data_Path="/www/server/data"

	mkdir -p ${Setup_Path}
	rm -rf ${Setup_Path}/*
	cd ${Setup_Path}
	if [ ! -f "${Setup_Path}/src.tar.gz" ];then
		wget -O ${Setup_Path}/src.tar.gz  ${download_Url}/src/mysql-boost-${mysql_80}.tar.gz -T20
	fi
	tar -zxvf src.tar.gz
	mv mysql-${mysql_80} src
	cd src 

	mkdir install
	cd install

	cmake .. -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DENABLED_LOCAL_INFILE=1 -DWITH_BOOST=../boost
	make -j${cpuCore}
	make install

	cd ..

	groupadd mysql
	useradd -s /sbin/nologin -M -g mysql mysql
	cat > /etc/my.cnf<<EOF
[client]
#password   = your_password
port        = 3306
socket      = /tmp/mysql.sock

[mysqld]
port        = 3306
socket      = /tmp/mysql.sock
datadir = ${Data_Path}
skip-external-locking
performance_schema_max_table_instances=400
table_definition_cache=400
key_buffer_size = 16M
max_allowed_packet = 1G
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
tmp_table_size = 16M
sql-mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
default_authentication_plugin=mysql_native_password
lower_case_table_names=1

explicit_defaults_for_timestamp = true
#skip-networking
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535

log-bin=mysql-bin
binlog_format=mixed
server-id   = 1
binlog_expire_logs_seconds = 600000
slow_query_log=1
slow-query-log-file=${Data_Path}/mysql-slow.log
long_query_time=3
#log_queries_not_using_indexes=on
early-plugin-load = ""

#loose-innodb-trx=0
#loose-innodb-locks=0
#loose-innodb-lock-waits=0
#loose-innodb-cmp=0
#loose-innodb-cmp-per-index=0
#loose-innodb-cmp-per-index-reset=0
#loose-innodb-cmp-reset=0
#loose-innodb-cmpmem=0
#loose-innodb-cmpmem-reset=0
#loose-innodb-buffer-page=0
#loose-innodb-buffer-page-lru=0
#loose-innodb-buffer-pool-stats=0
#loose-innodb-metrics=0
#loose-innodb-ft-default-stopword=0
#loose-innodb-ft-inserted=0
#loose-innodb-ft-deleted=0
#loose-innodb-ft-being-deleted=0
#loose-innodb-ft-config=0
#loose-innodb-ft-index-cache=0
#loose-innodb-ft-index-table=0
#loose-innodb-sys-tables=0
#loose-innodb-sys-tablestats=0
#loose-innodb-sys-indexes=0
#loose-innodb-sys-columns=0
#loose-innodb-sys-fields=0
#loose-innodb-sys-foreign=0
#loose-innodb-sys-foreign-cols=0

default_storage_engine = InnoDB
innodb_data_home_dir = ${Data_Path}
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = ${Data_Path}
innodb_buffer_pool_size = 16M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 120
innodb_max_dirty_pages_pct = 90
innodb_read_io_threads = 4
innodb_write_io_threads = 4

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF
    MySQL_Opt
    if [ -d "${Data_Path}" ]; then
        rm -rf ${Data_Path}/*
    else
        mkdir -p ${Data_Path}
    fi
    chown -R mysql:mysql ${Data_Path}
    ${Setup_Path}/bin/mysqld --initialize-insecure --basedir=${Setup_Path} --datadir=${Data_Path} --user=mysql
    chgrp -R mysql ${Setup_Path}/.
    \cp ${Setup_Path}/support-files/mysql.server /etc/init.d/mysqld
    chmod 755 /etc/init.d/mysqld
    sed -i '/case "$mode" in/i\ulimit -s unlimited' /etc/init.d/mysqld
    cat > /etc/ld.so.conf.d/mysql.conf<<EOF
${Setup_Path}/lib
/usr/local/lib
EOF

	#启动服务
    ldconfig
    ln -sf ${Setup_Path}/lib/mysql /usr/lib/mysql
    ln -sf ${Setup_Path}/include/mysql /usr/include/mysql
	/etc/init.d/mysqld start
	
	#设置软链
    SetLink
	ldconfig
	
	#设置密码
    ${Setup_Path}/bin/mysqladmin -u root password "${mysqlpwd}"
		
	#添加到服务列表
	update-rc.d mysqld defaults
	
	cd ${Setup_Path}
	rm -f src.tar.gz
	rm -rf src
	echo "${mysql_80}" > ${Setup_Path}/version.pl
	echo "${mysql_80}" > ${Setup_Path}/version_check.pl
	echo "True" > ${Setup_Path}/mysqlDb3.pl
	if [ ! -f "${Setup_Path}/bin/mysqld" ];then
		echo '========================================================'
		echo -e "\033[31mERROR: mysql-8.0 installation failed.\033[0m";
		rm -rf ${Setup_Path}
		exit 0;
	fi
}

Install_AliSQL()
{
	Close_MySQL
	cd ${run_path}
	#准备安装
	Setup_Path="/www/server/mysql"
	Data_Path="/www/server/data"
	
	
	mkdir -p ${Setup_Path}
	rm -rf ${Setup_Path}/*
	cd ${Setup_Path}
	if [ ! -f "${Setup_Path}/src.tar.gz" ];then
		wget -O ${Setup_Path}/src.zip ${download_Url}/src/alisql-master.zip -T20
	fi
	unzip src.zip
	mv AliSQL-master src
	cd src
	
	groupadd mysql
    useradd -s /sbin/nologin -M -g mysql mysql
	yum install bison-2.7 -y
    cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DDEFAULT_CHARSET=utf8   -DDEFAULT_COLLATION=utf8_general_ci -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DMYSQL_DATADIR=${Data_Path} -DMYSQL_TCP_PORT=3306 -DENABLE_DOWNLOADS=1
	make -j${cpuCore}
	make install
	
	if [ ! -f "${Setup_Path}/bin/mysqld" ];then
		echo '========================================================'
		echo -e "\033[31mERROR: AliSQL-$alisql_version installation failed.\033[0m";
		rm -rf ${Setup_Path}
		exit 0;
	fi

	    cat > /etc/my.cnf<<EOF
[client]
#password   = your_password
port        = 3306
socket      = /tmp/mysql.sock

[mysqld]
port        = 3306
socket      = /tmp/mysql.sock
datadir = ${Data_Path}
skip-external-locking
performance_schema_max_table_instances=400
table_definition_cache=400
key_buffer_size = 4M
max_allowed_packet = 100G
table_open_cache = 32
sort_buffer_size = 256K
net_buffer_length = 8K
read_buffer_size = 128K
read_rnd_buffer_size = 256K
myisam_sort_buffer_size = 4M
thread_cache_size = 4
query_cache_size = 4M
tmp_table_size = 8M

explicit_defaults_for_timestamp = true

#skip-networking
#skip-name-resolve
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535
sql-mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

log-bin=mysql-bin
binlog_format=mixed
server-id   = 1
expire_logs_days = 10
slow_query_log=1
slow-query-log-file=${Data_Path}/mysql-slow.log
long_query_time=3
#log_queries_not_using_indexes=on

#loose-innodb-trx=0
#loose-innodb-locks=0
#loose-innodb-lock-waits=0
#loose-innodb-cmp=0
#loose-innodb-cmp-per-index=0
#loose-innodb-cmp-per-index-reset=0
#loose-innodb-cmp-reset=0
#loose-innodb-cmpmem=0
#loose-innodb-cmpmem-reset=0
#loose-innodb-buffer-page=0
#loose-innodb-buffer-page-lru=0
#loose-innodb-buffer-pool-stats=0
#loose-innodb-metrics=0
#loose-innodb-ft-default-stopword=0
#loose-innodb-ft-inserted=0
#loose-innodb-ft-deleted=0
#loose-innodb-ft-being-deleted=0
#loose-innodb-ft-config=0
#loose-innodb-ft-index-cache=0
#loose-innodb-ft-index-table=0
#loose-innodb-sys-tables=0
#loose-innodb-sys-tablestats=0
#loose-innodb-sys-indexes=0
#loose-innodb-sys-columns=0
#loose-innodb-sys-fields=0
#loose-innodb-sys-foreign=0
#loose-innodb-sys-foreign-cols=0

default_storage_engine = InnoDB
innodb_data_home_dir = ${Data_Path}
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = ${Data_Path}
innodb_buffer_pool_size = 16M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 120
innodb_max_dirty_pages_pct = 90
innodb_read_io_threads = 4
innodb_write_io_threads = 4

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF

    
    MySQL_Opt
    if [ -d "${Data_Path}" ]; then
        rm -rf ${Data_Path}/*
    else
        mkdir -p ${Data_Path}
    fi
	
	chown -R mysql:mysql $Setup_Path
	chown -R mysql:mysql $Data_Path
    #chown -R mysql:mysql ${Data_Path}
    ${Setup_Path}/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=${Setup_Path} --datadir=${Data_Path} --user=mysql
    chgrp -R mysql ${Setup_Path}/.
    \cp support-files/mysql.server /etc/init.d/mysqld
    chmod 755 /etc/init.d/mysqld
	sed -i "s#\"\$\*\"#--sql-mode=\"NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\"#" /etc/init.d/mysqld

    cat > /etc/ld.so.conf.d/mysql.conf<<EOF
    ${Setup_Path}/lib
    /usr/local/lib
EOF
	
	
	#启动服务
    ldconfig
	chown mysql:mysql /etc/my.cnf
    ln -sf ${Setup_Path}/lib/mysql /usr/lib/mysql
    ln -sf ${Setup_Path}/include/mysql /usr/include/mysql
	/etc/init.d/mysqld start
	
	#设置软链
    SetLink
	ldconfig
	
	
	#设置密码
    ${Setup_Path}/bin/mysqladmin -u root password "${mysqlpwd}"
	
	#添加到服务列表
    update-rc.d mysqld defaults
	
	cd ${Setup_Path}
	rm -f src.zip
	rm -rf src
	echo "AliSQL $alisql_version" > ${Setup_Path}/version.pl
}


Install_Mariadb_55(){
	Close_MySQL
	cd ${run_path}
	#准备安装
	mkdir -p ${Setup_Path}
	rm -rf ${Setup_Path}/*
	cd ${Setup_Path}
	if [ ! -f "${Setup_Path}/src.tar.gz" ];then
		wget -O ${Setup_Path}/src.tar.gz ${download_Url}/src/mariadb-$mariadb_55.tar.gz -T20
	fi
	tar -zxvf src.tar.gz
	mv mariadb-$mariadb_55 src
	cd src
	
	#编译
	
	cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 
	make -j${cpuCore}
	make install
	
	#创建用户
	groupadd mysql
	useradd -s /sbin/nologin -M -g mysql mysql

	#写出配置文件
		cat > /etc/my.cnf<<EOF
[client]
#password	= your_password
port		= 3306
socket		= /tmp/mysql.sock

[mysqld]
port		= 3306
socket		= /tmp/mysql.sock
user    = mariadb
datadir = ${Data_Path}
basedir = ${Setup_Path}
log_error = ${Data_Path}/mariadb.err
#pid-file = ${Data_Path}/mariadb.pid
default_storage_engine = MyISAM
#skip-external-locking
#loose-skip-innodb
key_buffer_size = 8M
max_allowed_packet = 100G
table_open_cache = 32
sort_buffer_size = 256K
net_buffer_length = 4K
read_buffer_size = 128K
read_rnd_buffer_size = 256K
myisam_sort_buffer_size = 4M
thread_cache_size = 4
query_cache_size = 4M
tmp_table_size = 8M

#skip-networking
#skip-name-resolve
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535

log-bin=mysql-bin
binlog_format=mixed
server-id	= 1
expire_logs_days = 10

default_storage_engine = InnoDB
innodb_data_home_dir = ${Data_Path}
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = ${Data_Path}
innodb_buffer_pool_size = 16M
innodb_additional_mem_pool_size = 2M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 120
innodb_max_dirty_pages_pct = 90
innodb_read_io_threads = 4
innodb_write_io_threads = 4

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF

	MySQL_Opt
	#处理数据目录
	if [ -d "${Data_Path}" ]; then
		rm -rf ${Data_Path}/*
		else
			mkdir -p ${Data_Path}
		fi
		chown -R mysql:mysql ${Data_Path}
		${Setup_Path}/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=${Setup_Path} --datadir=${Data_Path} --user=mysql
		${Setup_Path}/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=${Setup_Path} --datadir=${Data_Path} --user=mysql
		chgrp -R mysql ${Setup_Path}/.
		\cp support-files/mysql.server /etc/init.d/mysqld
		chmod 755 /etc/init.d/mysqld
		sed -i "s#\"\$\*\"#--sql-mode=\"NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\"#" /etc/init.d/mysqld

		cat > /etc/ld.so.conf.d/mysql.conf<<EOF
${Setup_Path}/lib
/usr/local/lib
EOF

	

	#启动服务
    ldconfig
	#chown mysql:mysql /etc/my.cnf
    ln -sf ${Setup_Path}/lib/mysql /usr/lib/mysql
    ln -sf ${Setup_Path}/include/mysql /usr/include/mysql

	/etc/init.d/mysqld start

	#设置软链
    SetLink
	ldconfig

	#设置密码
    ${Setup_Path}/bin/mysqladmin -u root password "${mysqlpwd}"
	
	#添加到服务列表
    update-rc.d mysqld defaults
    
    service mysqld start
	
	cd ${Setup_Path}
	rm -f src.tar.gz
	rm -rf src
	echo "mariadb_${mariadb_55}" > ${Setup_Path}/version.pl
	
	
}

Install_Mariadb_100(){
	Close_MySQL
	cd ${run_path}
	#准备安装
	mkdir -p ${Setup_Path}
	rm -rf ${Setup_Path}/*
	cd ${Setup_Path}
	if [ ! -f "${Setup_Path}/src.tar.gz" ];then
		wget -O ${Setup_Path}/src.tar.gz ${download_Url}/src/mariadb-$mariadb_100.tar.gz -T20
	fi
	tar -zxvf src.tar.gz
	mv mariadb-$mariadb_100 src
	cd src
	
	#编译
	
	cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 ${withOpenssl}


	make -j${cpuCore}
	make install
	
	#创建用户
	groupadd mysql
	useradd -s /sbin/nologin -M -g mysql mysql

	#写出配置文件
		cat > /etc/my.cnf<<EOF
[client]
#password	= your_password
port		= 3306
socket		= /tmp/mysql.sock

[mysqld]
port		= 3306
socket		= /tmp/mysql.sock
user    = mysql
datadir = ${Data_Path}
basedir = ${Setup_Path}
log_error = ${Data_Path}/mariadb.err
#pid-file = ${Data_Path}/mariadb.pid
default_storage_engine = MyISAM
#skip-external-locking
#loose-skip-innodb
key_buffer_size = 16M
max_allowed_packet = 100G
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 4
query_cache_size = 8M
tmp_table_size = 16M

#skip-networking
#skip-name-resolve
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535

log-bin=mysql-bin
binlog_format=mixed
server-id	= 1
expire_logs_days = 10
slow_query_log=1
slow-query-log-file=${Data_Path}/mysql-slow.log
long_query_time=3
#log_queries_not_using_indexes=on

default_storage_engine = InnoDB
innodb_data_home_dir = ${Data_Path}
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = ${Data_Path}
innodb_buffer_pool_size = 16M
innodb_additional_mem_pool_size = 2M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 120
innodb_max_dirty_pages_pct = 90
innodb_read_io_threads = 4
innodb_write_io_threads = 4

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF

	MySQL_Opt
	#处理数据目录
	if [ -d "${Data_Path}" ]; then
		rm -rf ${Data_Path}/*
		else
			mkdir -p ${Data_Path}
		fi
		chown -R mysql:mysql ${Data_Path}
		${Setup_Path}/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=${Setup_Path} --datadir=${Data_Path} --user=mysql
		${Setup_Path}/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=${Setup_Path} --datadir=${Data_Path} --user=mysql
		chgrp -R mysql ${Setup_Path}/.
		\cp support-files/mysql.server /etc/init.d/mysqld
		chmod 755 /etc/init.d/mysqld
		sed -i "s#\"\$\*\"#--sql-mode=\"NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\"#" /etc/init.d/mysqld
		sed -i '/case "$mode" in/i\ulimit -s unlimited' /etc/init.d/mysqld
		cat > /etc/ld.so.conf.d/mysql.conf<<EOF
${Setup_Path}/lib
/usr/local/lib
EOF

	

	#启动服务
    ldconfig
	#chown mysql:mysql /etc/my.cnf
    ln -sf ${Setup_Path}/lib/mysql /usr/lib/mysql
    ln -sf ${Setup_Path}/include/mysql /usr/include/mysql

	/etc/init.d/mariadb start

	#设置软链
    SetLink
	ldconfig

	#设置密码
    ${Setup_Path}/bin/mysqladmin -u root password "${mysqlpwd}"
	
	#添加到服务列表
    update-rc.d mysqld defaults

	service mysqld start

	
	cd ${Setup_Path}
	rm -f src.tar.gz
	rm -rf src
	echo "mariadb_${mariadb_100}" > ${Setup_Path}/version.pl
	
	
}

Install_Mariadb_101(){
	Close_MySQL
	cd ${run_path}
	#准备安装
	mkdir -p ${Setup_Path}
	rm -rf ${Setup_Path}/*
	cd ${Setup_Path}
	if [ ! -f "${Setup_Path}/src.tar.gz" ];then
		wget -O ${Setup_Path}/src.tar.gz ${download_Url}/src/mariadb-$mariadb_101.tar.gz -T20
	fi
	tar -zxvf src.tar.gz
	mv mariadb-$mariadb_101 src
	cd src
	
	#编译
	
	cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITHOUT_TOKUDB=1 ${withOpenssl}
	make -j${cpuCore}
	make install
	
	#创建用户
	groupadd mysql
	useradd -s /sbin/nologin -M -g mysql mysql

	#写出配置文件
		cat > /etc/my.cnf<<EOF
[client]
#password	= your_password
port		= 3306
socket		= /tmp/mysql.sock

[mysqld]
port		= 3306
socket		= /tmp/mysql.sock
user    = mysql
datadir = ${Data_Path}
basedir = ${Setup_Path}
log_error = ${Data_Path}/mariadb.err
#pid-file = ${Data_Path}/mariadb.pid
default_storage_engine = MyISAM
#skip-external-locking
#loose-skip-innodb
key_buffer_size = 16M
max_allowed_packet = 100G
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
query_cache_size = 8M
tmp_table_size = 16M
sql-mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

#skip-networking
#skip-name-resolve
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535

log-bin=mysql-bin
binlog_format=mixed
server-id	= 1
expire_logs_days = 10
slow_query_log=1
slow-query-log-file=${Data_Path}/mysql-slow.log
long_query_time=3
#log_queries_not_using_indexes=on

default_storage_engine = InnoDB
innodb_data_home_dir = ${Data_Path}
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = ${Data_Path}
innodb_buffer_pool_size = 16M
innodb_additional_mem_pool_size = 2M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 120
innodb_max_dirty_pages_pct = 90
innodb_read_io_threads = 4
innodb_write_io_threads = 4

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF

	MySQL_Opt
	#处理数据目录
	if [ -d "${Data_Path}" ]; then
		rm -rf ${Data_Path}/*
		else
			mkdir -p ${Data_Path}
		fi
		chown -R mysql:mysql ${Data_Path}
		${Setup_Path}/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=${Setup_Path} --datadir=${Data_Path} --user=mysql
		${Setup_Path}/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=${Setup_Path} --datadir=${Data_Path} --user=mysql
		chgrp -R mysql ${Setup_Path}/.
		\cp support-files/mysql.server /etc/init.d/mysqld
		chmod 755 /etc/init.d/mysqld
		sed -i "s#\"\$\*\"#--sql-mode=\"NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\"#" /etc/init.d/mysqld
		sed -i '/case "$mode" in/i\ulimit -s unlimited' /etc/init.d/mysqld
		cat > /etc/ld.so.conf.d/mysql.conf<<EOF
${Setup_Path}/lib
/usr/local/lib
EOF

	

	#启动服务
    ldconfig
	#chown mysql:mysql /etc/my.cnf
    ln -sf ${Setup_Path}/lib/mysql /usr/lib/mysql
    ln -sf ${Setup_Path}/include/mysql /usr/include/mysql

	/etc/init.d/mysqld start

	#设置软链
	SetLink
	ldconfig

	#设置密码
    ${Setup_Path}/bin/mysqladmin -u root password "${mysqlpwd}"
	
	#添加到服务列表
    update-rc.d mysqld defaults

	service mysqld start
	
	cd ${Setup_Path}
	rm -f src.tar.gz
	rm -rf src
	echo "mariadb_${mariadb_101}" > ${Setup_Path}/version.pl
	
}
Install_Mariadb_102(){
	Close_MySQL
	cd ${run_path}
	#准备安装
	mkdir -p ${Setup_Path}
	rm -rf ${Setup_Path}/*
	cd ${Setup_Path}
	if [ ! -f "${Setup_Path}/src.tar.gz" ];then
		wget -O ${Setup_Path}/src.tar.gz ${download_Url}/src/mariadb-$mariadb_102.tar.gz -T20
	fi
	tar -zxvf src.tar.gz
	mv mariadb-$mariadb_102 src
	cd src
	
	#编译
	
	cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITHOUT_TOKUDB=1 ${withOpenssl}
	make -j{cpuCore}
	make install
	
	#创建用户
	groupadd mysql
	useradd -s /sbin/nologin -M -g mysql mysql

	#写出配置文件
		cat > /etc/my.cnf<<EOF
[client]
#password	= your_password
port		= 3306
socket		= /tmp/mysql.sock

[mysqld]
port		= 3306
socket		= /tmp/mysql.sock
user    = mysql
datadir = ${Data_Path}
basedir = ${Setup_Path}
log_error = ${Data_Path}/mariadb.err
#pid-file = ${Data_Path}/mariadb.pid
default_storage_engine = MyISAM
#skip-external-locking
#loose-skip-innodb
key_buffer_size = 16M
max_allowed_packet = 100G
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
query_cache_size = 8M
tmp_table_size = 16M
sql-mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

#skip-networking
#skip-name-resolve
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535

log-bin=mysql-bin
binlog_format=mixed
server-id	= 1
expire_logs_days = 10
slow_query_log=1
slow-query-log-file=${Data_Path}/mysql-slow.log
long_query_time=3
#log_queries_not_using_indexes=on

default_storage_engine = InnoDB
innodb_data_home_dir = ${Data_Path}
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = ${Data_Path}
innodb_buffer_pool_size = 16M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 120
innodb_max_dirty_pages_pct = 90
innodb_read_io_threads = 4
innodb_write_io_threads = 4

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF

	MySQL_Opt
	#处理数据目录
	if [ -d "${Data_Path}" ]; then
		rm -rf ${Data_Path}/*
		else
			mkdir -p ${Data_Path}
		fi
		chown -R mysql:mysql ${Data_Path}
		${Setup_Path}/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=${Setup_Path} --datadir=${Data_Path} --user=mysql
		chgrp -R mysql ${Setup_Path}/.
		\cp support-files/mysql.server /etc/init.d/mysqld
		chmod 755 /etc/init.d/mysqld
		sed -i "s#\"\$\*\"#--sql-mode=\"NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\"#" /etc/init.d/mysqld

		cat > /etc/ld.so.conf.d/mysql.conf<<EOF
${Setup_Path}/lib
/usr/local/lib
EOF

	

	#启动服务
    ldconfig
	#chown mysql:mysql /etc/my.cnf
    ln -sf ${Setup_Path}/lib/mysql /usr/lib/mysql
    ln -sf ${Setup_Path}/include/mysql /usr/include/mysql

	/etc/init.d/mysqld start

	#设置软链
    SetLink
	ldconfig

	#设置密码
    ${Setup_Path}/bin/mysqladmin -u root password "${mysqlpwd}"
	
	#添加到服务列表
	update-rc.d mysqld defaults
	/etc/init.d/mysqld start
	
	cd ${Setup_Path}
	rm -f src.tar.gz
	rm -rf src
	echo "mariadb_${mariadb_102}" > ${Setup_Path}/version.pl
	echo "True" > ${Setup_Path}/mysqlDb3.pl
	
}
Install_Mariadb_103(){
	Close_MySQL
	cd ${run_path}
	#准备安装
	mkdir -p ${Setup_Path}
	rm -rf ${Setup_Path}/*
	cd ${Setup_Path}
	if [ ! -f "${Setup_Path}/src.tar.gz" ];then
		wget -O ${Setup_Path}/src.tar.gz ${download_Url}/src/mariadb-$mariadb_103.tar.gz -T20
	fi
	tar -zxvf src.tar.gz
	mv mariadb-$mariadb_103 src
	cd src
	
	#编译
	
	cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITHOUT_TOKUDB=1 ${withOpenssl}
	make -j{cpuCore}
	make install
	
	#创建用户
	groupadd mysql
	useradd -s /sbin/nologin -M -g mysql mysql

	#写出配置文件
		cat > /etc/my.cnf<<EOF
[client]
#password	= your_password
port		= 3306
socket		= /tmp/mysql.sock

[mysqld]
port		= 3306
socket		= /tmp/mysql.sock
user    = mysql
datadir = ${Data_Path}
basedir = ${Setup_Path}
log_error = ${Data_Path}/mariadb.err
#pid-file = ${Data_Path}/mariadb.pid
default_storage_engine = MyISAM
#skip-external-locking
#loose-skip-innodb
key_buffer_size = 16M
max_allowed_packet = 100G
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
query_cache_size = 8M
tmp_table_size = 16M
sql-mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

#skip-networking
#skip-name-resolve
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535

log-bin=mysql-bin
binlog_format=mixed
server-id	= 1
expire_logs_days = 10
slow_query_log=1
slow-query-log-file=${Data_Path}/mysql-slow.log
long_query_time=3
#log_queries_not_using_indexes=on

default_storage_engine = InnoDB
innodb_data_home_dir = ${Data_Path}
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = ${Data_Path}
innodb_buffer_pool_size = 16M
innodb_log_file_size = 5M
innodb_log_buffer_size = 8M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 120
innodb_max_dirty_pages_pct = 90
innodb_read_io_threads = 4
innodb_write_io_threads = 4

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF

	MySQL_Opt
	#处理数据目录
	if [ -d "${Data_Path}" ]; then
		rm -rf ${Data_Path}/*
		else
			mkdir -p ${Data_Path}
		fi
		chown -R mysql:mysql ${Data_Path}
		${Setup_Path}/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=${Setup_Path} --datadir=${Data_Path} --user=mysql
		chgrp -R mysql ${Setup_Path}/.
		\cp support-files/mysql.server /etc/init.d/mysqld
		chmod 755 /etc/init.d/mysqld
		sed -i "s#\"\$\*\"#--sql-mode=\"NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\"#" /etc/init.d/mysqld

		cat > /etc/ld.so.conf.d/mysql.conf<<EOF
${Setup_Path}/lib
/usr/local/lib
EOF

	

	#启动服务
    ldconfig
	#chown mysql:mysql /etc/my.cnf
    ln -sf ${Setup_Path}/lib/mysql /usr/lib/mysql
    ln -sf ${Setup_Path}/include/mysql /usr/include/mysql

	/etc/init.d/mysqld start

	#设置软链
    SetLink
	ldconfig

	#设置密码
    ${Setup_Path}/bin/mysqladmin -u root password "${mysqlpwd}"
	
	#添加到服务列表
	update-rc.d mysqld defaults
	/etc/init.d/mysqld start
	
	cd ${Setup_Path}
	rm -f src.tar.gz
	rm -rf src
	echo "mariadb_${mariadb_103}" > ${Setup_Path}/version.pl
	echo "True" > ${Setup_Path}/mysqlDb3.pl
	
}
Update_MySQL_55(){
	cd ${run_path}
	mkdir -p ${Setup_Path}/update
	rm -rf ${Setup_Path}/update/*
	cd ${Setup_Path}/update
	wget -O ${Setup_Path}/update/src.tar.gz ${download_Url}/src/mysql-$mysql_55.tar.gz -T20
	tar -zxvf src.tar.gz
	mv mysql-$mysql_55 src
	cd src
	cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
	make -j${cpuCore}
	/etc/init.d/mysqld stop
	sleep 2
	make install
	sleep 2
	/etc/init.d/mysqld start
	echo "${mysql_55}" > ${Setup_Path}/version.pl
}
Update_MySQL_56(){
	cd ${run_path}
	mkdir -p ${Setup_Path}/update
	rm -rf ${Setup_Path}/update/*
	cd ${Setup_Path}/update
	wget -O ${Setup_Path}/update/src.tar.gz ${download_Url}/src/mysql-$mysql_56.tar.gz -T20
	tar -zxvf src.tar.gz
	mv mysql-$mysql_56 src
	cd src
	cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
	make -j${cpuCore}
	/etc/init.d/mysqld stop
	sleep 2
	make install
	sleep 2
	/etc/init.d/mysqld start
	echo "${mysql_56}" > ${Setup_Path}/version.pl
}
Update_MySQL_57(){
	cd ${run_path}
	wget ${download_Url}/src/boost_1_59_0.tar.gz -T20
	tar -zxvf boost_1_59_0.tar.gz
	cd boost_1_59_0
	
    ./bootstrap.sh
    ./b2
    ./b2 install
	
	cd ..
    rm -rf boost_1_59_0
	rm -f boost_1_59_0.tar.gz
	mkdir -p ${Setup_Path}/update
	rm -rf ${Setup_Path}/update/*
	cd ${Setup_Path}/update
	wget -O ${Setup_Path}/update/src.tar.gz ${download_Url}/src/mysql-$mysql_57.tar.gz -T20
	tar -zxvf src.tar.gz
	mv mysql-$mysql_57 src
	cd src
	cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
	make -j${cpuCore}
	/etc/init.d/mysqld stop
	sleep 2
	make install
	sleep 2
	/etc/init.d/mysqld start
	echo "${mysql_57}" > ${Setup_Path}/version.pl
}
Update_AliSQL(){
	cd ${run_path}
	mkdir -p ${Setup_Path}/update
	rm -rf ${Setup_Path}/update/*
	cd ${Setup_Path}/update
	wget -O ${Setup_Path}/update/src.zip ${download_Url}/src/alisql-master.zip -T20
	unzip src.zip
	mv AliSQL-master src
	cd src
    cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DDEFAULT_CHARSET=utf8   -DDEFAULT_COLLATION=utf8_general_ci -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DMYSQL_DATADIR=${Data_Path} -DMYSQL_TCP_PORT=3306 -DENABLE_DOWNLOADS=1
	make -j${cpuCore}
	/etc/init.d/mysqld stop
	sleep 2
	make install
	sleep 2
	/etc/init.d/mysqld start
	echo "AliSQL $alisql_version" > ${Setup_Path}/version.pl
}
Update_Mariadb_100(){
	cd ${run_path}
	mkdir -p ${Setup_Path}/update
	rm -rf ${Setup_Path}/update/*
	cd ${Setup_Path}/update
	wget -O ${Setup_Path}/update/src.tar.gz ${download_Url}/src/mariadb-$mariadb_100.tar.gz -T20
	tar -zxvf src.tar.gz
	mv mariadb-$mariadb_100 src
	cd src
	cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1
	make -j${cpuCore}
	/etc/init.d/mysqld stop
	sleep 2
	make install
	sleep 2
	/etc/init.d/mysqld start
	echo "mariadb_${mariadb_100}" > ${Setup_Path}/version.pl
}
Update_Mariadb_101(){
	cd ${run_path}
	mkdir -p ${Setup_Path}/update
	rm -rf ${Setup_Path}/update/*
	cd ${Setup_Path}/update
	wget -O ${Setup_Path}/update/src.tar.gz ${download_Url}/src/mariadb-$mariadb_101.tar.gz -T20
	tar -zxvf src.tar.gz
	mv mariadb-$mariadb_101 src
	cd src
	cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITHOUT_TOKUDB=1
	make -j${cpuCore}
	/etc/init.d/mysqld stop
	sleep 2
	make install
	sleep 2
	/etc/init.d/mysqld start
	echo "mariadb_${mariadb_101}" > ${Setup_Path}/version.pl
}
Update_Mariadb_102(){
	cd ${run_path}
	mkdir -p ${Setup_Path}/update
	rm -rf ${Setup_Path}/update/*
	cd ${Setup_Path}/update
	wget -O ${Setup_Path}/update/src.tar.gz ${download_Url}/src/mariadb-$mariadb_102.tar.gz -T20
	tar -zxvf src.tar.gz
	mv mariadb-$mariadb_102 src
	cd src
	cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITHOUT_TOKUDB=1
	make -j${cpuCore}
	/etc/init.d/mysqld stop
	sleep 2
	make install
	sleep 2
	/etc/init.d/mysqld start
	echo "mariadb_${mariadb_102}" > ${Setup_Path}/version.pl
}
Update_Mariadb_103(){
	cd ${run_path}
	mkdir -p ${Setup_Path}/update
	rm -rf ${Setup_Path}/update/*
	cd ${Setup_Path}/update
	wget -O ${Setup_Path}/update/src.tar.gz ${download_Url}/src/mariadb-$mariadb_103.tar.gz -T20
	tar -zxvf src.tar.gz
	mv mariadb-$mariadb_103 src
	cd src
	cmake -DCMAKE_INSTALL_PREFIX=${Setup_Path} -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITHOUT_TOKUDB=1
	make -j${cpuCore}
	/etc/init.d/mysqld stop
	sleep 2
	make install
	sleep 2
	/etc/init.d/mysqld start
	echo "mariadb_${mariadb_103}" > ${Setup_Path}/version.pl
}
MySQL_Opt()
{
	cpuInfo=`cat /proc/cpuinfo |grep "processor"|wc -l`
	sed -i 's/innodb_write_io_threads = 4/innodb_write_io_threads = '${cpuInfo}'/g' /etc/my.cnf
	sed -i 's/innodb_read_io_threads = 4/innodb_read_io_threads = '${cpuInfo}'/g' /etc/my.cnf
	MemTotal=`free -m | grep Mem | awk '{print  $2}'`
    if [[ ${MemTotal} -gt 1024 && ${MemTotal} -lt 2048 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 32M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 128#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 768K#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 768K#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 8M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 16#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 16M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 32M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 128M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 64M#" /etc/my.cnf
        sed -i "s#^innodb_log_buffer_size.*#innodb_log_buffer_size = 16M#" /etc/my.cnf
    elif [[ ${MemTotal} -ge 2048 && ${MemTotal} -lt 4096 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 64M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 256#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 1M#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 1M#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 16M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 32#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 32M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 64M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 256M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 128M#" /etc/my.cnf
        sed -i "s#^innodb_log_buffer_size.*#innodb_log_buffer_size = 32M#" /etc/my.cnf
    elif [[ ${MemTotal} -ge 4096 && ${MemTotal} -lt 8192 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 128M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 512#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 2M#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 2M#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 32M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 64#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 64M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 64M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 512M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 256M#" /etc/my.cnf
        sed -i "s#^innodb_log_buffer_size.*#innodb_log_buffer_size = 64M#" /etc/my.cnf
    elif [[ ${MemTotal} -ge 8192 && ${MemTotal} -lt 16384 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 256M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 1024#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 4M#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 4M#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 64M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 128#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 128M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 128M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 1024M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 512M#" /etc/my.cnf
        sed -i "s#^innodb_log_buffer_size.*#innodb_log_buffer_size = 128M#" /etc/my.cnf
    elif [[ ${MemTotal} -ge 16384 && ${MemTotal} -lt 32768 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 512M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 2048#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 8M#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 8M#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 128M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 256#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 256M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 256M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 2048M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 1024M#" /etc/my.cnf
        sed -i "s#^innodb_log_buffer_size.*#innodb_log_buffer_size = 256M#" /etc/my.cnf
    elif [[ ${MemTotal} -ge 32768 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 1024M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 4096#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 16M#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 16M#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 256M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 512#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 512M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 512M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 4096M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 2048M#" /etc/my.cnf
        sed -i "s#^innodb_log_buffer_size.*#innodb_log_buffer_size = 256M#" /etc/my.cnf
        if [ "${version}" == "5.5" ];then
        	sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 1024M#" /etc/my.cnf
        	sed -i "s#^innodb_log_buffer_size.*#innodb_log_buffer_size = 256M#" /etc/my.cnf
        else
        	sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 2048M#" /etc/my.cnf
        	sed -i "s#^innodb_log_buffer_size.*#innodb_log_buffer_size = 512M#" /etc/my.cnf
        fi
    fi
}
Install_mysqldb()
{
	wget -O MySQL-python-1.2.5.zip ${download_Url}/install/src/MySQL-python-1.2.5.zip -T 10
	unzip MySQL-python-1.2.5.zip
	rm -f MySQL-python-1.2.5.zip
	cd MySQL-python-1.2.5
	python setup.py install
	cd ..
	rm -rf MySQL-python-1.2.5
}
Install_mysqldb3()
{
	wget -O mysqlclient-1.3.12.zip ${download_Url}/install/src/mysqlclient-1.3.12.zip -T 10
	unzip mysqlclient-1.3.12.zip
	rm -f mysqlclient-1.3.12.zip
	cd mysqlclient-1.3.12
	python setup.py install
	cd ..
	rm -rf mysqlclient-1.3.12
}
Close_MySQL()
{
	/etc/init.d/mysqld stop
	if [ "$1" == 'del' ];then
		rm -rf $Setup_Path
	fi
	
	if [ -d "${Data_Path}" ];then
		mkdir -p $Root_Path/backup
		mv $Data_Path  $Root_Path/backup/oldData
		rm -rf $Data_Path
	fi
	
	update-rc.d -f mysqld remove
	rm -f /etc/init.d/mysqld
	apt-get purge -y mysql-client mysql-server mysql-common mysql-server-core-5.5 mysql-client-5.5
	DelLink
}

Install_OpenSSL()
{
    if [ ! -d "/usr/local/openssl" ];then
        cd ${run_path}
        wget ${download_Url}/src/openssl-1.0.2l.tar.gz -T 20
        tar -zxf openssl-1.0.2l.tar.gz
        rm -f openssl-1.0.2l.tar.gz
        cd openssl-1.0.2l
        ./config --openssldir=/usr/local/openssl zlib-dynamic shared
        make && make install
        echo '1.0.2l_shared' > /usr/local/openssl/version.pl
        cd ..
        rm -rf openssl-1.0.2l
		cat > /etc/ld.so.conf.d/openssl.conf <<EOF
/usr/local/openssl/lib
EOF
ldconfig
    fi
}


actionType=$1
version=$2

if [ "$actionType" == 'install' ];then
	Openssl_Version=`openssl version | awk '{print $2}'`
	if [[ "${Openssl_Version}" =~ "1.1." ]]; then
		Install_OpenSSL
		withOpenssl="-DWITH_SSL=/usr/local/openssl"
	else
		withOpenssl=""
	fi
	mysqlpwd=`cat /dev/urandom | head -n 16 | md5sum | head -c 16`
	case "$version" in
		'5.1')
			Install_MySQL_51
			;;
		'5.5')
			Install_MySQL_55
			;;
		'5.6')
			Install_MySQL_56
			;;
		'5.7')
			Install_MySQL_57
			;;
		'8.0')
			Install_MySQL_80
			;;
		'alisql')
			Install_AliSQL
			;;
		'mariadb_5.5')
			Install_Mariadb_55
			;;		
		'mariadb_10.0')
			Install_Mariadb_100
			;;		
		'mariadb_10.1')
			Install_Mariadb_101
			;;
		'mariadb_10.2')
			Install_Mariadb_102
			;;
		'mariadb_10.3')
			Install_Mariadb_103
			;;
	esac
	/etc/init.d/mysqld start
	if [ -f '/www/server/panel/tools.py' ];then
		python /www/server/panel/tools.py root $mysqlpwd
	else
		python /www/server/panel/tools.pyc root $mysqlpwd
	fi
	sleep 1
	/etc/init.d/mysqld stop
	pkill -9 mysqld_safe
	pkill -9 mysql
	sleep 1
	/etc/init.d/mysqld start
	sleep 1
	/www/server/mysql/bin/mysql -uroot -p$mysqlpwd -e "drop database test";
	pyVersion=$(python -V 2>&1|awk '{printf ("%d",$2)}')
	if [ "${pyVersion}" == "2" ];then
		if [ -f "${Setup_Path}/mysqlDb3.pl" ]; then
			pip uninstall mysqlclient -y
			Install_mysqldb3
			/etc/init.d/bt reload
		else
			pip uninstall mysql-python -y
			Install_mysqldb
			/etc/init.d/bt reload
		fi
		pip uninstall pymysql -y
		pip install pymysql
	else
		pip uninstall pymysql -y
		pip install pymysql
	fi

elif [ "$actionType" == 'uninstall' ];then
	Close_MySQL del
elif [ "$actionType" == 'update' ]; then
	case "$version" in
		'5.5')
			Update_MySQL_55
			;;
		'5.6')
			Update_MySQL_56
			;;
		'5.7')
			Update_MySQL_57
			;;
		'alisql')
			Update_AliSQL
			;;
		'mariadb_5.5')
			Update_Mariadb_55
			;;		
		'mariadb_10.0')
			Update_Mariadb_100
			;;		
		'mariadb_10.1')
			Update_Mariadb_101
			;;
		'mariadb_10.2')
			Update_Mariadb_102
			;;
		'mariadb_10.3')
			Update_Mariadb_103
			;;
	esac
	if [ -f "/usr/bin/mysql" ]; then
		rm -rf ${Setup_Path}/src/*
		rm -rf ${Setup_Path}/update/*
	fi
	rm -f ${Setup_Path}/version_check.pl
	/etc/init.d/mysqld restart
fi
