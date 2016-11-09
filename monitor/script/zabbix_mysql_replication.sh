#!/bin/sh
MYSQL_DIR=/usr/local/mysql56
MYSQL=${MYSQL_DIR}/bin/mysql
MYSQL_SOCK="/tmp/my3306.sock"
MYSQL_CONF="/data1/mysql3306/my3306.cnf"
ARGS=1
if [ $# -ne "$ARGS" ]; then
	echo "please input on argument:"
fi
case $1 in
	Repl_Status)
		result=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -e "show slave status\G" | egrep -w "Slave_IO_Running|Slave_SQL_Running" | awk '{print $2}' | grep -c Yes`
		if [[ $result -eq 2 ]];then
			echo "Yes"
		else
			echo "No"
		fi
		;;
	Repl_Delay)
		result=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -e"show slave status\G" | egrep -w "Seconds_Behind_Master" | awk '{print $2}'`
		echo $result
		;;
	Mysql_Alive)
		result=`ps -ef | grep mysqld_safe | grep -v grep | wc -l`
		echo $result
		if [[ $result -eq 0 ]]; then
			echo "Yes"
		else
			echo "No"
		fi
		;;
	Mysql_qps)
		rs1=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e "show global status where variable_name = 'Queries'" | awk '{print $2}'`
		sleep 1
		rs2=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e "show global status where variable_name = 'Queries'" | awk '{print $2}'`
		result=`expr $[rs2 - rs1]`
		echo $result
		;;
	Mysql_tps)
		rs1=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e "show global status where variable_name = 'Com_commit'" | awk '{print $2}'`
		rs2=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e "show global status where variable_name = 'Com_rollback'" | awk '{print $2}'`
		sleep 1
		rs11=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e "show global status where variable_name = 'Com_commit'" | awk '{print $2}'`
		rs21=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e "show global status where variable_name = 'Com_rollback'" | awk '{print $2}'`
		result=`expr $[rs11 + rs21 - rs1 - rs2]`
		echo $result
		;;
	*)
	echo "Usage:$0(Repl_Status|Repl_Delay|Mysql_Alive)"
	;;
esac