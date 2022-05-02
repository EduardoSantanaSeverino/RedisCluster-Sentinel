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

echo ' Installing jq - Start'
sudo apt -y install jq
echo ' Installing jq - End'

cd haproxy-docker

# pass the NODES as 1
if ["$1"] 
then
    echo "Argument supplied is: $1"
    NODES=$1
else
    echo "NO Argument supplied FOR NODES."
    NODES="[ '192.168.22.131','192.168.22.132','192.168.22.133' ]"
fi

COUNTER=1

# Replace single quotes with double.
NODES=${NODES//[\']/\"}

cat haproxy.conf > haproxy.conf.temp

for row in $(echo "${NODES}" | jq -r '.[]'); do
    echo $row
    echo "	server redis-$COUNTER $row:6379 check inter 1s" >> haproxy.conf.temp
    COUNTER=`expr $COUNTER + 1`
done

echo ' docker-compose up -d - Start'
docker-compose up -d 
echo ' docker-compose up -d - End'