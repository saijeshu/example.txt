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

dnf install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "instaling python"

useradd roboshop &>> $LOGFILE

VALIDATE $? "adding useradd"

mkdir /app &>> $LOGFILE

VALIDATE $? "creating directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE

VALIDATE $? "downloading pym application"

cd /app &>> $LOGFILE

VALIDATE $? "changing directory"

unzip /tmp/payment.zip &>> $LOGFILE

VALIDATE $? "unzip payment"

pip3.6 install -r requirements.txt &>> $LOGFILE

VALIDATE $? "instaling pip"

cp /home/centos/example.txt/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "Copying payment service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon reaload"

systemctl enable payment  &>> $LOGFILE

VALIDATE $? "Enable payment"

systemctl start payment &>> $LOGFILE

VALIDATE $? "Start payment"