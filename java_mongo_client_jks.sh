#!/bin/bash

yes | keytool -import -file mongoCA.crt -alias mongo-client -keystore mongo-client-truststore.jks -storepass trustme

openssl pkcs12 -export -out mongo-client.p12 -in mongo-client.crt -inkey mongo-client.key -name mongo-client -passin pass:trustme -passout pass:trustme -certfile mongoCA.crt

keytool -noprompt -importkeystore -deststorepass trustme -destkeypass trustme -destkeystore mongo-client-keystore.jks -srckeystore mongo-client.p12 -srcstoretype PKCS12 -srcstorepass trustme -deststoretype JKS -srcalias mongo-client 

keytool -list -v -keystore mongo-client-keystore.jks -storepass trustme -keypass trustme
keytool -list -v -keystore mongo-client-truststore.jks -storepass trustme -keypass trustme
