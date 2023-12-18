#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script strated executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $? -ne 0 ]
    then
       echo -e "$2...$R FAILED $N"
       exit 1
    else
       echo -e "$2...$G SUCCESS $N" 
    fi   
}

if [ $ID -ne 0 ]
then
   echo -e "$R ERROE:: Please run script with root access $N "
else
  echo "you have root access"
fi

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "disabling mysql"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "coping mysql"

dnf install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "installing mysql"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "enabling mysql"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "set root pass mysql"






