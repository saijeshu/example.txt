#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.sandhyadevops.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current NodeJS"

dnf module enable nodejs:18 -y  &>> $LOGFILE

VALIDATE $? "Enabling NodeJS:18"

dnf install nodejs -y  &>> $LOGFILE

VALIDATE $? "Installing NodeJS:18"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app

VALIDATE $? "creating app directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "downloading user application"

cd /app 

VALIDATE $? "changing directory"

unzip /tmp/user.zip &>> $LOGFILE

VALIDATE $? "unzipping user file"

npm install &>> $LOGFILE

VALIDATE $? "installing nodejs dependencies"

cp /home/centos/example.txt/user.service /etc/systemd/system/user.service &>> $LOGFILE

VALIDATE $? "copying user service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "loading user service"

systemctl enable user &>> $LOGFILE 

VALIDATE $? "enabling user service"

systemctl start user &>> $LOGFILE

VALIDATE $? "starting user"

cp /home/centos/example.txt/mongo.repo /etc/systemd/system/mongo.repo &>> $LOGFILE

VALIDATE $? "coping mongo repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongodb"

mongo --host MONGDB_HOST </app/schema/user.js &>> $LOGFILE

VALIDATE $? "uploading mongodb data"





