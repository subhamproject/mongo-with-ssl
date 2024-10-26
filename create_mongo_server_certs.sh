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


PATH="."

function server_cert() {
NAME=$1
SERVER_KEY="$PATH/$NAME.key"
SERVER_CSR="$PATH/$NAME.csr"
SERVER_CRT="$PATH/$NAME.crt"
SERVER_PEM="$PATH/$NAME.pem"
}


CA_KEY="$PATH/mongoCA.key"
CA_CRT="$PATH/mongoCA.crt"
CA_EXTFILE="$PATH/mongo_ca_cert.cnf"
MONGO_SERVER_EXT="$PATH/mongo_server_ext.cnf"
MONGO_SERVER_CONF="$PATH/mongo_server_cert.cnf"
OPENSSL_CMD="/usr/bin/openssl"
CAT_CMD="/usr/bin/cat"

function generate_root_ca {

    ## generate rootCA private key
    echo "Generating RootCA private key"
    if [[ ! -f $CA_KEY ]];then
       $OPENSSL_CMD genrsa -out $CA_KEY 2048 2>/dev/null
       [[ $? -ne 0 ]] && echo "ERROR: Failed to generate $CA_KEY" && exit 1
    else
       echo "$CA_KEY seems to be already generated, skipping the generation of RootCA certificate"
       return 0
    fi

    ## generate rootCA certificate
    echo "Generating RootCA certificate"
    $OPENSSL_CMD req -new -x509 -days 3650 -config $CA_EXTFILE -key $CA_KEY -out $CA_CRT 2>/dev/null
    [[ $? -ne 0 ]] && echo "ERROR: Failed to generate $CA_CRT" && exit 1

    ## read the certificate
    echo "Verify RootCA certificate"
    $OPENSSL_CMD  x509 -noout -text -in $CA_CRT >/dev/null 2>&1
    [[ $? -ne 0 ]] && echo "ERROR: Failed to read $CA_CRT" && exit 1
}

function generate_server_certificate {
    server_cert $1
    echo "Generating server private key"
    $OPENSSL_CMD genrsa -out $SERVER_KEY 2048 2>/dev/null
    [[ $? -ne 0 ]] && echo "ERROR: Failed to generate $SERVER_KEY" && exit 1

    echo "Generating certificate signing request for server"
    $OPENSSL_CMD req -new -key $SERVER_KEY -out $SERVER_CSR -config $MONGO_SERVER_CONF 2>/dev/null
    [[ $? -ne 0 ]] && echo "ERROR: Failed to generate $SERVER_CSR" && exit 1

    echo "Generating RootCA signed server certificate"
    $OPENSSL_CMD x509 -req -in $SERVER_CSR -CA $CA_CRT -CAkey $CA_KEY -out $SERVER_CRT -CAcreateserial -days 365 -sha512 -extfile $MONGO_SERVER_EXT 2>/dev/null
    [[ $? -ne 0 ]] && echo "ERROR: Failed to generate $SERVER_CRT" && exit 1

    echo "Verifying the server certificate against RootCA"
    $OPENSSL_CMD verify -CAfile $CA_CRT $SERVER_CRT >/dev/null 2>&1
     [[ $? -ne 0 ]] && echo "ERROR: Failed to verify $SERVER_CRT against $CA_CRT" && exit 1

    echo "Concatenate the key and the signed Certificate"
    $CAT_CMD $SERVER_KEY $SERVER_CRT > $SERVER_PEM
    [[ $? -ne 0 ]] && echo "ERROR: Failed to Create Pem $SERVER_PEM against $SERVER_CRT" && exit 1

}

# MAIN
generate_root_ca
for server in mongo1 mongo2 mongo3;do
generate_server_certificate $server
done

================================================================================================

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

OUTPUT_DIR="."  # Use OUTPUT_DIR instead of PATH to avoid overriding system paths

function server_cert() {
    NAME=$1
    SERVER_KEY="$OUTPUT_DIR/$NAME.key"
    SERVER_CSR="$OUTPUT_DIR/$NAME.csr"
    SERVER_CRT="$OUTPUT_DIR/$NAME.crt"
    SERVER_PEM="$OUTPUT_DIR/$NAME.pem"
}

CA_KEY="$OUTPUT_DIR/mongoCA.key"
CA_CRT="$OUTPUT_DIR/mongoCA.crt"
CA_EXTFILE="$OUTPUT_DIR/mongo_ca_cert.cnf"
MONGO_SERVER_EXT="$OUTPUT_DIR/mongo_server_ext.cnf"
MONGO_SERVER_CONF="$OUTPUT_DIR/mongo_server_cert.cnf"
OPENSSL_CMD="/usr/bin/openssl"
CAT_CMD="/usr/bin/cat"

function generate_root_ca {
    echo "Generating RootCA private key"
    if [[ ! -f $CA_KEY ]]; then
        $OPENSSL_CMD genrsa -out $CA_KEY 2048 2>/dev/null
        [[ $? -ne 0 ]] && die "ERROR: Failed to generate $CA_KEY"
    else
        echo "$CA_KEY already exists, skipping generation."
        return 0
    fi

    echo "Generating RootCA certificate"
    $OPENSSL_CMD req -new -x509 -days 3650 -config $CA_EXTFILE -key $CA_KEY -out $CA_CRT 2>/dev/null
    [[ $? -ne 0 ]] && die "ERROR: Failed to generate $CA_CRT"

    echo "Verifying RootCA certificate"
    $OPENSSL_CMD x509 -noout -text -in $CA_CRT >/dev/null 2>&1
    [[ $? -ne 0 ]] && die "ERROR: Failed to read $CA_CRT"
}

function generate_server_certificate {
    server_cert $1
    echo "Generating server private key for $1"
    $OPENSSL_CMD genrsa -out $SERVER_KEY 2048 2>/dev/null
    [[ $? -ne 0 ]] && die "ERROR: Failed to generate $SERVER_KEY"

    echo "Generating certificate signing request for $1"
    $OPENSSL_CMD req -new -key $SERVER_KEY -out $SERVER_CSR -config $MONGO_SERVER_CONF 2>/dev/null
    [[ $? -ne 0 ]] && die "ERROR: Failed to generate $SERVER_CSR"

    echo "Generating RootCA signed server certificate for $1"
    $OPENSSL_CMD x509 -req -in $SERVER_CSR -CA $CA_CRT -CAkey $CA_KEY -out $SERVER_CRT -CAcreateserial -days 365 -sha512 -extfile $MONGO_SERVER_EXT 2>/dev/null
    [[ $? -ne 0 ]] && die "ERROR: Failed to generate $SERVER_CRT"

    echo "Verifying the server certificate for $1 against RootCA"
    $OPENSSL_CMD verify -CAfile $CA_CRT $SERVER_CRT >/dev/null 2>&1
    [[ $? -ne 0 ]] && die "ERROR: Failed to verify $SERVER_CRT against $CA_CRT"

    echo "Concatenating the key and the signed Certificate for $1"
    $CAT_CMD $SERVER_KEY $SERVER_CRT > $SERVER_PEM
    [[ $? -ne 0 ]] && die "ERROR: Failed to create PEM $SERVER_PEM"
}

# MAIN
generate_root_ca
for server in mongo1 mongo2 mongo3; do
    generate_server_certificate $server
done
