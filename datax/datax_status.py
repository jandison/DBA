#!/bin/env python
#coding=utf8

import os
import sys
import time
import logging
import logging.handlers
import pymysql

today = int(time.time())
timeArray = time.localtime(today)
dates = time.strftime("%Y-%m-%d",timeArray)
MYSQL_HOST="116.62.180.176"
MYSQL_POSR=3306
MYSQL_USER="datax"
MYSQL_PASSWORD="creauniondatax!"
DB="datax"
TMP_LOG="tmp_logfile.tmp"
LOG_FILE = '/opt/tools/datax/log/%s/datax_status_sync.log' % dates
handler = logging.handlers.RotatingFileHandler(LOG_FILE,maxBytes=1024 * 1024,backupCount=5)
fmt = '%(asctime)s - %(filename)s:%(lineno)s - %(name)s - %(message)s'
formatter = logging.Formatter(fmt)
handler.setFormatter(formatter)
logger = logging.getLogger("datax status")
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)

cmd = 'cd /opt/tools/datax/log/%s && grep "读写失败总数" *.log | awk -F ":" {\'print $1\'} > %s' % (dates,TMP_LOG)
res = os.system(cmd)
if res != 0:
	logger.error("获取日志文件失败,请检查日志是否正常生成!")
	sys.exit(1)
else:
	try:
		logfile = open("/opt/tools/datax/log/%s/%s" % (dates,TMP_LOG),"r")
		mysqlConn = pymysql.connect(host=MYSQL_HOST,user=MYSQL_USER,password=MYSQL_PASSWORD,db=DB)
		mysqlCursor = mysqlConn.cursor()
		for line in logfile.readlines():
			logname = line.strip('\n')
			logger.info("正在处理文件-%s" % logname)
			cmd = 'cd /opt/tools/datax/log/%s && tail -8 %s | awk -F \' :\' \'{gsub(//,"",$2);print $2}\' > process.tmp' % (dates,logname)
			res = os.system(cmd)
			if res != 0:
				logger.error("生成临时处理文件错误")
				sys.exit(1)
			else:
				logfile = open("/opt/tools/datax/log/%s/process.tmp" % dates,"r")
				mylist = []
				for line in logfile.readlines():
					mylist.append(line.strip('\n'))
				sql = 'insert into datax_status(id,job_name,monitor_date,job_starttime,job_endtime,duration,avg_io,avg_speed,read_total,error_total) values(null,\'%s\',date(now()),\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\',\'%s\')' % (logname,mylist[0],mylist[1],mylist[2],mylist[3].lstrip().rstrip(),mylist[4].lstrip().rstrip(),mylist[5],mylist[6])
				mysqlCursor.execute(sql)
				logfile.close()
	except Exception as e:
		logger.error(e)
		mysqlConn.rollback()
	finally:
		logfile.close()
		mysqlConn.commit()
		mysqlConn.close()

			

