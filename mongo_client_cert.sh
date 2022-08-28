#!/bin/bash

openssl req -new -nodes -out mongo-client.csr -config mongo_client_cert.cnf
openssl x509 -req -in mongo-client.csr -CA mongoCA.crt -CAkey mongoCA.key -out mongo-client.crt -CAcreateserial -days 365 -sha256  -extensions v3_ca
cat mongo-client.key mongo-client.crt > mongo-client.pem
