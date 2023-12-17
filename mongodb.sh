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
    else
       echo -e "$2...$G SUCCESS $N" 
    fi   
}

if [ $ID -ne 0 ]
then
   echo -e "$R ERROE:: Please run script with root access $N "
   exit 1
else
  echo "you have root access"
fi
 
cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "Copied Mongodb repo"

dnf install mongodb-org -y $LOGFILE

VALIDATE $? "Installing MongoDB"
  
systemctl enable mongod $LOGFILE

VALIDATE $? "enabling MongoDB"

systemctl start mongod $LOGFILE

VALIDATE $? "starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE

VALIDATE $? "remote access to MongoDB"

systemctl restart mongod

VALIDATE $? "restarting MongoDB"

