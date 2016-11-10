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
	Repl_status)
		result=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -e "show slave status\G" | egrep -w "Slave_IO_Running|Slave_SQL_Running" | awk '{print $2}' | grep -c Yes`
		if [[ $result -eq 2 ]];then
			echo "Yes"
		else
			echo "No"
		fi
		;;
	Repl_delay)
		result=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -e"show slave status\G" | egrep -w "Seconds_Behind_Master" | awk '{print $2}'`
		echo $result
		;;
	Mysql_alive)
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
		#sleep 1
		#rs2=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e "show global status where variable_name = 'Queries'" | awk '{print $2}'`
		#result=`expr $[rs2 - rs1]`
		echo $rs1
		;;
	Mysql_tps)
		rs1=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e "show global status where variable_name = 'Com_commit'" | awk '{print $2}'`
		rs2=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e "show global status where variable_name = 'Com_rollback'" | awk '{print $2}'`
		result=`expr $[rs1 + rs2]`
		echo $result
		;;
	Mysql_slowqueries)
		result=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e"show global status where variable_name = 'slow_queries'" | awk '{print $2}'`
		#sleep 10
		#rs2=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e"show global status where variable_name = 'slow_queries'" | awk '{print $2}'`
		#result=`expr $[rs1 - rs2]`
		echo $result
		;;
	Mysql_threadconnected)
		result=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e"show global status where variable_name = 'Threads_connected'" | awk '{print $2}'`
		echo $result
		;;
	Mysql_createdtmpdisktables)
		result=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e"show global status where variable_name = 'Created_tmp_disk_tables'" | awk '{print $2}'`
		echo $result
		;;
	Mysql_handlerreadfirst)
		result=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e"show global status where variable_name = 'Handler_read_first'" | awk '{print $2}'`
		echo $result
		;;
	Mysql_innodbbufferpoolwaitfree)
		result=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e"show global status where variable_name = 'Innodb_buffer_pool_wait_free'" | awk '{print $2}'`
		echo $result
		;;
	Mysql_keyreads)
		result=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e"show global status where variable_name = 'Key_reads'" | awk '{print $2}'`
		echo $result
		;;
	Mysql_maxusedconnections)
		result=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e"show global status where variable_name = 'Max_used_connections'" | awk '{print $2}'`
		echo $result
		;;
	Mysql_opentables)
		result=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e"show global status where variable_name = 'Open_tables'" | awk '{print $2}'`
		echo $result
		;;
	Mysql_selectfulljoin)
		result=`${MYSQL} --defaults-extra-file=${MYSQL_CONF} -N -e"show global status where variable_name = 'Select_full_join'" | awk '{print $2}'`
		echo $result
		;;
	*)
	echo "Usage:$0(Repl_status|Repl_delay|Mysql_alive|Mysql_qps|Mysql_tps|Mysql_slowqueries|Mysql_threadconnected|Mysql_createdtmpdisktables|Mysql_handlerreadfirst|Mysql_innodbbufferpoolwaitfree|Mysql_keyreads|Mysql_maxusedconnections|Mysql_opentables|Mysql_selectfulljoin)"
	;;
esac