#!/bin/bash
#start mysql for 163 dba


PATH=$PATH:/home/dba/bin:/home/ddb/bin:/usr/local/mysql55/bin
export LANG=en_US.UTF-8


function  usage()
{
	echo "usage:  sh  $0 -P port" 
}

if [[ "$#" -ne 2 ]]  
then
     usage
     exit 1
fi
password=4fqqoucUdDTSlpsi
MUSER=`echo $USER`
datadir=/data1
version=55

while getopts P:h: OPTION
do
   case "$OPTION" in
       P)port=$OPTARG
       ;;
       h)usage
         exit 0
       ;;
       *)
           usage      
            exit 1
          ;;
   esac
done

port_exist=`netstat -an|grep LISTEN|grep tcp|grep $port|wc -l`
if [ $port_exist -ne 0 ]
then
        echo "$port exist"
        exit 1
fi

version=`cat $datadir/mysql$port/my$port.cnf|grep mysql_version|awk -F'=' '{print $2}'`
if [ $version = mysql55 ]
then  
	mysql=/usr/local/mysql55
elif [ $version = mysql56 ];then  
	mysql=/usr/local/mysql56
else
        mysql=/usr/local/mysql55
fi
new_init=1
innodb_log_group_exist=`cat $datadir/mysql$port/my$port.cnf |grep innodb_log_group_home_dir|wc -l`
if [ $innodb_log_group_exist -eq 1 ]
then
	innodb_log_group_dir=`cat $datadir/mysql$port/my$port.cnf|grep innodb_log_group_home_dir|awk -F '=' '{print $2}'`
	iblog="$innodb_log_group_dir/ib_logfile0"
	if [ ! -f $iblog ]
	then
		new_init=0
	fi
fi



if [ -d $mysql ]
then 
	echo "start mysql,waiting..."
	cd $mysql
	./bin/mysqld_safe --defaults-file=$datadir/mysql$port/my$port.cnf >/dev/null 2>&1 &
else
   echo "Not found $mysqlstart error"
   echo "you must have $mysql directory"
   exit 1
fi
if [ $new_init -eq 0 ]
then
	if [ ! -d $datadir/mysql$port/dba ]
	then
		sleep 30
		port_exist=`netstat -an|grep LISTEN|grep tcp|grep $port|wc -l`
		if [ $port_exist -eq 0 ]
		then
			sleep 60
		fi
		socket=`ls /tmp/mysql$port\.sock|wc -l`
		if [ $socket -eq 0 ]
	        then
	                sleep 60	
        	fi
		host="`echo $HOSTNAME`"
		$mysql/bin/mysql -S /tmp/mysql$port.sock -uroot -e "grant all on *.* to root@'localhost' identified by '$password';" 2>/dev/null
		$mysql/bin/mysql -S /tmp/mysql$port.sock -uroot -p$password -e "grant all on *.* to dba_mgr@'127.0.0.1' identified by 'o7xeJMkJOeqGWH1X';" 2>/dev/null
		$mysql/bin/mysql -S /tmp/mysql$port.sock -uroot -p$password -e 'drop user root@127.0.0.1;' 2>/dev/null
		$mysql/bin/mysql -S /tmp/mysql$port.sock -uroot -p$password -e 'drop user root@"::1";'     2>/dev/null
		$mysql/bin/mysql -S /tmp/mysql$port.sock -uroot -p$password -e 'drop user ""@localhost;'   2>/dev/null
		$mysql/bin/mysql -S /tmp/mysql$port.sock -uroot -p$password -e "drop user ''@'$host';"   2>/dev/null
		$mysql/bin/mysql -S /tmp/mysql$port.sock -uroot -p$password -e "drop user root@'$host';" 2>/dev/null
		$mysql/bin/mysql -S /tmp/mysql$port.sock -uroot -p$password -e "flush privileges;" 2>/dev/null
		$mysql/bin/mysql -S /tmp/mysql$port.sock -uroot -p$password -e 'reset master'
	fi
fi



