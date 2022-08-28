#!/bin/bash

multi_ssl() {
case $ROLE in
  master)
   certname="mongo1.pem"
     [ "$( ps -ef|grep mongod|grep -v grep|wc -l)" -ge "1" ] && kill -9 $(ps -ef | grep mongod | grep -v grep | awk '{print $2}')
     sleep 5
     /usr/bin/mongod  --auth --clusterAuthMode x509  --dbpath /data/db --port 27017  --bind_ip_all --sslMode requireSSL --replSet "rs0" --sslPEMKeyFile /certs/$certname --sslCAFile /certs/mongoCA.crt &
     ;;
  slave)
 case `hostname` in
    mongo2)
    certname="mongo2.pem"
    [ "$( ps -ef|grep mongod|grep -v grep|wc -l)" -ge "1" ] && kill -9 $(ps -ef | grep mongod | grep -v grep | awk '{print $2}')
    sleep 5
   /usr/bin/mongod  --auth --clusterAuthMode x509  --dbpath /data/db --port 27017  --bind_ip_all --sslMode requireSSL --replSet "rs0" --sslPEMKeyFile /certs/$certname --sslCAFile /certs/mongoCA.crt &
   ;;
   mongo3)
   certname="mongo3.pem"
    [ "$( ps -ef|grep mongod|grep -v grep|wc -l)" -ge "1" ] && kill -9 $(ps -ef | grep mongod | grep -v grep | awk '{print $2}')
    sleep 5
   /usr/bin/mongod  --auth --clusterAuthMode x509  --dbpath /data/db --port 27017  --bind_ip_all --sslMode requireSSL --replSet "rs0" --sslPEMKeyFile /certs/$certname --sslCAFile /certs/mongoCA.crt &
   ;;
esac
;;
*)  echo "ERROR: Unknown role $ROLE!"; exit 1
esac
}
