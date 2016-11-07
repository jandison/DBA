#!/bin/bash
#stop mysql for 360 dba


export LANG=en_US.UTF-8

function  usage()
{
	echo "usage:  sh  $0 -P port" 
}

if [[ "$#" -eq 0 ]]  
then
     usage
     exit 1
fi
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

socket=/tmp/mysql$port.sock

password=4fqqoucUdDTSlpsi

mysql=/usr/local/mysql55/
if [ -d $mysql ]
then
    $mysql/bin/mysqladmin -u root -p$password -S $socket shutdown
else
	echo "[Error]: Not found $mysql,please check"
	exit 1
fi

exit 0

