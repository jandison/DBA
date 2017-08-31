#!/bin/env python
#coding=utf8
import pymysql
import os
import smtplib
import time
from email.mime.text import MIMEText
from email.header import Header

mail_host="smtp.aliyun.com"
mail_user="jandison@aliyun.com"
mail_pass="liuzhi1987$"
sender = "jandison@aliyun.com"
receivers = ["283636912@qq.com"]

MYSQL_HOST="116.62.180.176"
MYSQL_POSR=3306
MYSQL_USER="datax"
MYSQL_PASSWORD="creauniondatax!"
DB="datax"

today = int(time.time())
timeArray = time.localtime(today)
dates = time.strftime("%Y-%m-%d",timeArray)

mysqlConn = pymysql.connect(host=MYSQL_HOST,user=MYSQL_USER,password=MYSQL_PASSWORD,db=DB)
mysqlCursor = mysqlConn.cursor()

sql="select concat('monitor date : [',monitor_date,'],total jobs : [',count(*),'],total time(s) : [', sum(duration),'],total rows : [',sum(read_total),'],total errors : [',sum(error_total),']') from datax_status where monitor_date = date(now())"

mysqlCursor.execute(sql)
result = ''
for r in mysqlCursor.fetchall():
	result = r
#print result
message = MIMEText(str(result),'plain','utf-8')
message['From'] = Header("大数据平台", 'utf-8')
message['To'] =  Header("Jandison", 'utf-8')
subject = 'datax数据同步结果'
message['Subject'] = Header(subject, 'utf-8')
try:
    smtpObj = smtplib.SMTP()
    smtpObj.connect(mail_host,25)
    smtpObj.login(mail_user,mail_pass)
    smtpObj.sendmail(sender, receivers, message.as_string())
    print "邮件发送成功"
except smtplib.SMTPException as e:
    print e
