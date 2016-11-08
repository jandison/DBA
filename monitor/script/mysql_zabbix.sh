#!/bin/bash
#Create by zhengdazhi 2014.09.22
MYSQL_DIR=/usr/local/mysql56
MYSQL=${MYSQL_DIR}/bin/mysql
#MYSQLADMIN=${MYSQL_DIR}/bin/mysqladmin
MYSQL_SOCK="/tmp/mysql3306.sock"
MYSQL_USER=root
MYSQL_PWD=4fqqoucUdDTSlpsi
FILE=/data1/mysql3306/my3306.cnf
ARGS=1 
if [ $# -ne "$ARGS" ];then 
  echo "Please input one arguement:"
fi
case $1 in
  Uptime) 
    result=`${MYSQL} --defaults-extra-file=$FILE -N -e "show global status like '$1'" |cut -f2 -d":"| awk '{print $2}'` 
      echo $result 
      ;; 
    Com_update) 
      result=`${MYSQL} --defaults-extra-file=$FILE -N -e "show global status like '$1'"|cut -f2 -d":"| awk '{print $2}'` 
      echo $result 
      ;; 
    Slow_queries) 
    result=`${MYSQL} --defaults-extra-file=$FILE -N -e "show global status like '$1'"|cut -f2 -d":"| awk '{print $2}'` 
        echo $result 
        ;; 
  Com_select) 
    result=`${MYSQL} --defaults-extra-file=$FILE -N -e "show global status like '$1'"|cut -f2 -d":"| awk '{print $2}'` 
        echo $result 
        ;; 
  Com_rollback) 
    result=`${MYSQL} --defaults-extra-file=$FILE -N -e "show global status like '$1'"|cut -f2 -d":"| awk '{print $2}'` 
        echo $result 
        ;; 
  Questions) 
    result=`${MYSQL} --defaults-extra-file=$FILE -N -e "show global status like '$1'"|cut -f2 -d":"| awk '{print $2}'` 
        echo $result 
        ;; 
  Com_insert) 
    result=`${MYSQL} --defaults-extra-file=$FILE -N -e "show global status like '$1'"|cut -f2 -d":"| awk '{print $2}'` 
        echo $result 
        ;; 
  Com_delete) 
    result=`${MYSQL} --defaults-extra-file=$FILE -N -e "show global status like '$1'"|cut -f2 -d":"| awk '{print $2}'` 
        echo $result 
        ;; 
  Com_commit) 
    result=`${MYSQL} --defaults-extra-file=$FILE -N -e "show global status like '$1'"|cut -f2 -d":"| awk '{print $2}'` 
        echo $result 
        ;; 
  Bytes_sent) 
    result=`${MYSQL} --defaults-extra-file=$FILE -N -e "show global status like '$1'"|cut -f2 -d":"| awk '{print $2}'` 
        echo $result 
        ;; 
  Bytes_received) 
    result=`${MYSQL} --defaults-extra-file=$FILE -N -e "show global status like '$1'"|cut -f2 -d":"| awk '{print $2}'` 
        echo $result 
        ;; 
  Com_begin) 
    result=`${MYSQL} --defaults-extra-file=$FILE -N -e "show global status like '$1'"|cut -f2 -d":"| awk '{print $2}'` 
        echo $result 
        ;; 
  
    *) 
    echo "Usage:$0(Uptime|Com_update|Slow_queries|Com_select|Com_rollback|Questions)"
    ;; 
esac
