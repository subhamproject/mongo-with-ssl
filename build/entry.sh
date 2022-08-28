#!/bin/bash

source /usr/bin/add_user.sh
source /usr/bin/entry_ssl.sh

initdb() {
    sleep 5
    if [ "$( ps -ef|grep mongod|grep -v grep|wc -l)" -ge "1" ] ;then
    echo "Initiating Replica Set..."
    mongo --eval 'rs.initiate()'
    mongo --eval 'rs.slaveOk()'
    sleep 5
    create_user
    sleep 3
    fi
  }

case $ROLE in
  master)
     if [ -f "/usr/bin/dummy" ];then
     /usr/bin/mongod --smallfiles --replSet "rs0" --dbpath /data/db --port 27017 --bind_ip_all &
     initdb
     fi
     ;;
  slave)
    if [ -f "/usr/bin/dummy" ];then
    /usr/bin/mongod --smallfiles --replSet "rs0" --dbpath /data/db --port 27017 --bind_ip_all &
    fi
     ;;
  *)
   echo "ERROR: Unknown mode $ROLE!"; exit 1
        ;;
  esac

sleep 20
multi_ssl
[ -f /usr/bin/dummy ] && rm -rf /usr/bin/dummy > /dev/null 2>&1

tail -f /dev/null
