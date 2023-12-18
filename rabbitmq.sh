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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "downloading from java provider"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE

VALIDATE $? "downloading rabbitmq"

dnf install rabbitmq-server -y &>> $LOGFILE

VALIDATE $? "installing rabbitmq"

systemctl enable rabbitmq-server &>> $LOGFILE

VALIDATE $? "enabling rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE

VALIDATE $? " adding user rabbitmq"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE

VALIDATE $? "set rabbitmq"