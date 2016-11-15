#!/bin/bash
### Author : Jandison
### date : 2015-08-12
### Func : init mysql 


PATH=/usr/local/jdk1.6.0_45/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/mysql56/bin:

export LANG=en_US.UTF-8
version='56'
versions='mysql56'
mem=2
slave=0

#MUSER=`echo $USER`
MUSER=dba
daemon_dir=/usr/local/mysql$version



usage()
{
echo "usage:  
	sh  $0 -p port -m mem -s 1 -v version" 
echo "e.g.       
	sh  $0 -p 3999 -m 3 -s 1 -v mysql56" 
echo "        
	-m	mem:default 2
		unit:GB"
echo "        
	-s	slave:default 0
		1:slave,0:master"
echo "       
	-v	version:default mysql56 
		optional:mysql55,mysql56"
}


while getopts p:v:s:m:h OPTION
do
   case "$OPTION" in
       p)port=$OPTARG
       ;;
       v)versions=$OPTARG
       ;;
       m)mem=$OPTARG
       ;;
       s)slave=$OPTARG
       ;;
       h)usage;
         exit 0
       ;;
       *)usage;
         exit 1
       ;;
   esac
done

if [[ "$#" -eq 0 ]]
  then
     usage
     exit 1
fi

data_dir=/data1/mysql$port
log_dir=/data1/mysql$port

if_port_exit=`netstat -lnp|grep :$port|wc -l`
if [ $if_port_exit -gt 0 ]
  then
    echo "the $port exist"
    exit 1
fi


if [ -d $data_dir ]||[ -d $log_dir ]
then
        echo "the $data_dir $log_dir is exists,you must check"
	exit 1
else
        mkdir -p $data_dir   $log_dir
fi

getip()
{
ip=`ifconfig | grep "inet addr" | cut -f 2 -d ":" | cut -f 1 -d " " | head -1`
echo $ip
}


function init_data()
{
cat > $data_dir/my$port.cnf  << EOF

##mysql cnf
[mysqld]

# GENERAL con#
user                           = $MUSER
port                           = $port
default_storage_engine         = InnoDB
socket                         = /tmp/mysql$port.sock
pid_file                       = /data1/mysql$port/mysql.pid

#slave
#read_only
#log-slave-updates

# MyISAM #
#key_buffer_size                = 32M
key_buffer              	= 32M
myisam_recover                 = FORCE,BACKUP

# SAFETY #
max_allowed_packet             = 64M
max_connect_errors             = 1000000

# DATA STORAGE #binlog-format
datadir                        = /data1/mysql$port/

# BINARY LOGGING #
log_bin                        = /data1/mysql$port/$port-binlog
expire_logs_days               = 10
#sync_binlog                    = 1
relay-log=  /data1/mysql$port/$port-relaylog
#replicate-wild-do-table=hostility_url.%
#replicate-wild-do-table=guards.%



# CACHES AND LIMITS #
tmp_table_size                 = 32M
max_heap_table_size            = 32M
query_cache_type               = 1
query_cache_size               = 0
max_connections                = 5000
#max_user_connections          = 200
thread_cache_size              = 512
open_files_limit               = 65535
table_definition_cache         = 4096
table_open_cache               = 4096
wait_timeout=7500
interactive_timeout=7500
binlog-format=mixed
character-set-server=utf8
skip-name-resolve 
skip-character-set-client-handshake
back_log=1024


# INNODB #
innodb_flush_method            = O_DIRECT
innodb_data_home_dir = /data1/mysql$port/
innodb_data_file_path = ibdata1:1G:autoextend
innodb_log_group_home_dir=/data1/mysql$port/
innodb_log_files_in_group      = 3
innodb_log_file_size           = 1G
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table          = 1
innodb_file_format=Barracuda 
innodb_support_xa=0


innodb_io_capacity=500
innodb_max_dirty_pages_pct=90
innodb_read_io_threads=16
innodb_write_io_threads=8
innodb_buffer_pool_instances=4
innodb_thread_concurrency=0


# LOGGING #
log_error                      = /data1/mysql$port/error.log
#log_queries_not_using_indexes  = 1
slow_query_log                 = 1
slow_query_log_file            = /data1/mysql$port/mysql-slow.log
long_query_time = 0.05
log_queries_not_using_indexes = 1

# 该参数只在5.6及以上版本中使用
# 表示每分钟记录的slow log的且未使用到索引的SQL语句次数
# 默认为0，表示没有限制；生产环境中，若没有限制，慢查询会被频繁记录到slow log，导致文件不断增大，DBA可适当调整
log_throttle_queries_not_using_indexes = 0 
EOF

# if [ $slave -eq 1 ]
# then
# 	echo "read_only">>$data_dir/my$port.cnf
# fi

serverid=`getip|awk -F . '{print $1$2$3$4}'`
ipadd=`getip`
sid=$serverid$port
server_id=`echo $sid % 4000000000 | bc`
#echo "server_id=$serverid$port">>$data_dir/my$port.cnf
echo "server_id=$server_id">>$data_dir/my$port.cnf
echo 'innodb_buffer_pool_size        = '$mem'G'>>$data_dir/my$port.cnf
#echo "skip-slave-start">>$data_dir/my$port.cnf
echo "report-host=$ipadd">>$data_dir/my$port.cnf
echo "report-port=$port">>$data_dir/my$port.cnf

echo "### mysql_version=$versions" >> $data_dir/my$port.cnf


echo "[mysql]
prompt = \\u@\\h:\\p [\\d]>" >> $data_dir/my$port.cnf


$daemon_dir/scripts/mysql_install_db --user=$MUSER --basedir=$daemon_dir --datadir=/data1/mysql$port

if [ $? -eq 0 ]
then
        echo "$Port init ok"
	exit 0
else
	echo "$port init err"
	exit 1
fi
}

init_data
