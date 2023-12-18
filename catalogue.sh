#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.sandhyadevops.online

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
   echo -e "$R ERROE:: Please run script with root access $N"
else
  echo "you have root access"
fi
 
dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current nodejs" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling nodejs:18" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing nodejs" 

useradd roboshop &>> $LOGFILE

id roboshop
if  [ $? -ne 0 ]
then
   useradd roboshop
   VALIDATE$? "roboshop user creation"
else
    echo -e " already user exit $Y SKIPPING $N"
fi   

VALIDATE $? "creating roboshopuser" 

mkdir -p /app 

VALIDATE $? "creating app directory" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "downloading catalog application" 

cd /app 

unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzipping the catalogue" 

npm install &>> $LOGFILE

VALIDATE $? "installing catalogue dependencies" 

cp /home/centos/example.txt/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? coping catlogue service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue daemon-reload"

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? " enabling catalogue" 

systemctl start catalogue &>> $LOGFILE

VALIDATE $? " starting catalogue" 

cp /home/centos/example.txt/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "coping mongodb repo "

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing Mongodb client"

mongo --host $MONGDB_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "loading catalogue data into mongodb"