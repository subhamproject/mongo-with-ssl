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




====================================================================================================

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
    [ ! -z "$(command -v openssl)" ] || die "The 'openssl' command is missing - Please install"
    [ ! -z "$(command -v keytool)" ] || die "The 'keytool' command is missing - Please install"
    [ ! -z "$(command -v docker)" ] || die "The 'docker' command is missing - Please install"
    [ ! -z "$(command -v docker-compose)" ] || die "The 'docker-compose' command is missing - Please install"
}

check_exist

# Define password variables for easier modification
PASSWORD="trustme"
CA_CERT="mongoCA.crt"
CLIENT_KEY="mongo-client.key"
CLIENT_CERT="mongo-client.crt"
TRUSTSTORE="mongo-client-truststore.jks"
KEYSTORE="mongo-client-keystore.jks"
PKCS12_FILE="mongo-client.p12"

# Function to import CA cert into truststore
function create_truststore() {
    if [[ -f $TRUSTSTORE ]]; then
        log "$TRUSTSTORE already exists, skipping creation."
    else
        log "Creating Truststore..."
        yes | keytool -import -file $CA_CERT -alias mongo-client -keystore $TRUSTSTORE -storepass $PASSWORD || die "Failed to create Truststore"
    fi
}

# Function to create PKCS12 file from client cert and key
function create_pkcs12() {
    if [[ -f $PKCS12_FILE ]]; then
        log "$PKCS12_FILE already exists, skipping creation."
    else
        log "Creating PKCS12 file..."
        openssl pkcs12 -export -out $PKCS12_FILE -in $CLIENT_CERT -inkey $CLIENT_KEY -name mongo-client -passin pass:$PASSWORD -passout pass:$PASSWORD -certfile $CA_CERT || die "Failed to create PKCS12 file"
    fi
}

# Function to create keystore from PKCS12 file
function create_keystore() {
    if [[ -f $KEYSTORE ]]; then
        log "$KEYSTORE already exists, skipping creation."
    else
        log "Creating Keystore..."
        keytool -noprompt -importkeystore -deststorepass $PASSWORD -destkeypass $PASSWORD -destkeystore $KEYSTORE -srckeystore $PKCS12_FILE -srcstoretype PKCS12 -srcstorepass $PASSWORD -deststoretype JKS -srcalias mongo-client || die "Failed to create Keystore"
    fi
}

# Function to verify keystore and truststore contents
function verify_stores() {
    log "Verifying Keystore contents..."
    keytool -list -v -keystore $KEYSTORE -storepass $PASSWORD -keypass $PASSWORD || die "Failed to list Keystore contents"

    log "Verifying Truststore contents..."
    keytool -list -v -keystore $TRUSTSTORE -storepass $PASSWORD || die "Failed to list Truststore contents"
}

# Main execution
create_truststore
create_pkcs12
create_keystore
verify_stores


keytool -noprompt -importkeystore -deststorepass trustme -destkeypass trustme -destkeystore mongo-client-keystore.jks -srckeystore mongo-client.p12 -srcstoretype PKCS12 -srcstorepass trustme -deststoretype JKS -srcalias mongo-client 

keytool -list -v -keystore mongo-client-keystore.jks -storepass trustme -keypass trustme
keytool -list -v -keystore mongo-client-truststore.jks -storepass trustme -keypass trustme
