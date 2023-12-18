#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGDB_HOST=mongodb.daws76s.online

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

dnf install maven -y &>> $LOGFILE

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir /app &>> $LOGFILE

VALIDATE $? "creating directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE

VALIDATE $? "downloading shipping"

cd /app &>> $LOGFILE

VALIDATE $? "changing directory"

unzip /tmp/shipping.zip &>> $LOGFILE

VALIDATE $? "unzipping directory"

mvn clean package &>> $LOGFILE

VALIDATE $? "cleanong mvn package"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE

VALIDATE $? " shipping jar file"

cp /home/centos/example.txt/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE

VALIDATE $? "coping shipping service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "reloading.."

systemctl enable shipping &>> $LOGFILE 

VALIDATE $? "enabling shipping"

systemctl start shipping &>> $LOGFILE

VALIDATE $? "start shipping"



dnf install mysql -y &>> $LOGFILE

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE

systemctl restart shipping &>> $LOGFILE