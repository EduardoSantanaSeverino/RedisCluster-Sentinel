#!/bin/bash

echo ' Update package list - Start'
sudo apt-get -y update
echo ' Update package list - End'

echo ' Update dist - Start'
sudo apt-get -y dist-upgrade 
echo ' Update dist - End'

echo ' Installing Docker.io - Start'
sudo apt -y install docker.io
echo ' Installing Docker.io - End'

echo ' Installing docker-compose - Start'
sudo apt -y install docker-compose
echo ' Installing docker-compose - End'

cd redis-a-docker

echo "" > .env

# pass the REDIS_MASTER as 1
if [ "$1" ] 
then
    echo "Argument supplied is: $1"
    echo "REDIS_MASTER=$1" >> .env
else
    echo "NO Argument supplied FOR REDIS_MASTER."
    echo "REDIS_MASTER=192.168.22.131" >> .env
fi

# pass the REDIS_A_HOST_IP as 2
if [ "$2" ] 
then
    echo "Argument supplied is: $2"
    echo "REDIS_A_HOST_IP=$2" >> .env
else
    echo "NO Argument supplied FOR REDIS_A_HOST_IP."
    echo "REDIS_A_HOST_IP=192.168.22.131" >> .env
fi

# pass the REDIS_A_PORT as 3
if [ "$3" ]
then
    echo "Argument supplied is: $3"
    echo "REDIS_A_PORT=$3" >> .env
else
    echo "NO Argument supplied FOR REDIS_A_PORT."
    echo "REDIS_A_PORT=6379" >> .env
fi

# pass the SENTINEL_A_PORT as 4
if [ "$4" ] 
then
    echo "Argument supplied is: $4"
    echo "SENTINEL_A_PORT=$4" >> .env
else
    echo "NO Argument supplied FOR SENTINEL_A_PORT."
    echo "SENTINEL_A_PORT=26379" >> .env
fi

# Load the env variables.
set -o allexport
[[ -f .env ]] && source .env
set +o allexport


if [ "$REDIS_MASTER" == "$REDIS_A_HOST_IP" ]
then
    echo "Both Strings are Equal."
    sed -i -e "s|slaveof REDIS_MASTER 6379|#|g" redis.conf
else
    echo "Both Strings are not Equal."
        
    SUB='1 received,'
    COUNTER=1

    while [ $COUNTER -lt 60 ];
    do 
        sleep 2
        PING_RESULTS=$(ping $REDIS_MASTER -c 1)

        if [[ "$PING_RESULTS" == *"$SUB"* ]]; then
            echo "------------------------------------------------------------------------"
            echo "[INFO] $SUB WAS FOUND." 
            echo "------------------------------------------------------------------------"
            COUNTER=60
        else
            echo "------------------------------------------------------------------------"
            echo "[ERROR] NOT FOUND THE $SUB, ON THE CONTENT, WAITING." 
            echo "------------------------------------------------------------------------"
            COUNTER=`expr $COUNTER + 1`
        fi
    done
fi

# Replace the Sorry Cypress project name.
sed -i -e "s|REDIS_MASTER|$REDIS_MASTER|g" data/sentinel.conf
sed -i -e "s|REDIS_MASTER|$REDIS_MASTER|g" redis.conf

echo ' docker-compose up -d - Start'
docker-compose up -d 
echo ' docker-compose up -d - End'