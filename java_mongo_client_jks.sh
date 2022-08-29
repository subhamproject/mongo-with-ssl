#!/bin/bash

function log() {
    echo "$1" >&2
}

function die() {
    log "$1"
    exit 1
}

function check_exist() {
    [ ! -z "$(command -v java)" ] || die "The 'java' command is missing - Please install"
    [ ! -z "$(command -v openssl)" ] || die "The the 'openssl' command is missing - Please install"
    [ ! -z "$(command -v keytool)" ] || die "The the 'keytool' command is missing - Please install"
    [ ! -z "$(command -v docker)" ] || die "The the 'docker' command is missing - Please install"
    [ ! -z "$(command -v docker-compose)" ] || die "The the 'docker-compose' command is missing - Please install"
}


check_exist


yes | keytool -import -file mongoCA.crt -alias mongo-client -keystore mongo-client-truststore.jks -storepass trustme

openssl pkcs12 -export -out mongo-client.p12 -in mongo-client.crt -inkey mongo-client.key -name mongo-client -passin pass:trustme -passout pass:trustme -certfile mongoCA.crt

keytool -noprompt -importkeystore -deststorepass trustme -destkeypass trustme -destkeystore mongo-client-keystore.jks -srckeystore mongo-client.p12 -srcstoretype PKCS12 -srcstorepass trustme -deststoretype JKS -srcalias mongo-client 

keytool -list -v -keystore mongo-client-keystore.jks -storepass trustme -keypass trustme
keytool -list -v -keystore mongo-client-truststore.jks -storepass trustme -keypass trustme
