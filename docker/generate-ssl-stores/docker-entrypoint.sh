#!/bin/sh

set -ex

KEY_STORE_PASSWORD=$1
TRUST_STORE_PASSWORD=$2

NODE_KEYSTORE=${WORKDIR}/ssl-stores/node-server-keystore.jks
REAPER_KEYSTORE=${WORKDIR}/ssl-stores/reaper-server-keystore.jks
GENERIC_TRUSTSTORE=${WORKDIR}/ssl-stores/generic-server-truststore.jks

GENERIC_CA_CERT_CONFIG=${WORKDIR}/generic_ca_cert.conf
ROOT_CA_CERT=${WORKDIR}/ssl-stores/ca-cert

echo "Generic Certificate Authority configuration"
cat ${GENERIC_CA_CERT_CONFIG}
echo

rm -r ${WORKDIR}/ssl-stores/*

# Create root Certificate Authority (CA) and verify contents.
openssl req -config ${GENERIC_CA_CERT_CONFIG} -new -x509 -keyout ca-key -out ${ROOT_CA_CERT}
openssl x509 -in ${ROOT_CA_CERT} -text -noout

# Generate public/private key pair and the key stores.
keytool -genkeypair -keyalg RSA -alias node -keystore ${NODE_KEYSTORE} -storepass ${KEY_STORE_PASSWORD} -keypass ${KEY_STORE_PASSWORD} -keysize 2048 -dname "CN=node, OU=SSL-verification-cluster, O=TheLastPickle, C=AU"
keytool -genkeypair -keyalg RSA -alias reaper -keystore ${REAPER_KEYSTORE} -storepass ${KEY_STORE_PASSWORD} -keypass ${KEY_STORE_PASSWORD} -keysize 2048 -dname "CN=reaper, OU=SSL-verification-cluster, O=TheLastPickle, C=AU"

# Export certificates from key stores as a 'Signing Request' for the CA.
keytool -keystore ${NODE_KEYSTORE} -alias node -certreq -file node_cert_sr -keypass ${KEY_STORE_PASSWORD} -storepass ${KEY_STORE_PASSWORD}
keytool -keystore ${REAPER_KEYSTORE} -alias reaper -certreq -file reaper_cert_sr -keypass ${KEY_STORE_PASSWORD} -storepass ${KEY_STORE_PASSWORD}

# Sign each of the certificates using the CA public key.
openssl x509 -req -CA ${ROOT_CA_CERT} -CAkey ca-key -in node_cert_sr -out node_cert_signed -CAcreateserial -passin pass:mypass
openssl x509 -req -CA ${ROOT_CA_CERT} -CAkey ca-key -in reaper_cert_sr -out reaper_cert_signed -CAcreateserial -passin pass:mypass

# Import the the root CA into the key stores.
keytool -keystore ${NODE_KEYSTORE} -alias CARoot -import -file ${ROOT_CA_CERT} -noprompt -keypass ${KEY_STORE_PASSWORD} -storepass ${KEY_STORE_PASSWORD}
keytool -keystore ${REAPER_KEYSTORE} -alias CARoot -import -file ${ROOT_CA_CERT} -noprompt -keypass ${KEY_STORE_PASSWORD} -storepass ${KEY_STORE_PASSWORD}

# Import the signed certificates back into the key stores.
keytool -keystore ${NODE_KEYSTORE} -alias node -import -file node_cert_signed -keypass ${KEY_STORE_PASSWORD} -storepass ${KEY_STORE_PASSWORD}
keytool -keystore ${REAPER_KEYSTORE} -alias reaper -import -file reaper_cert_signed -keypass ${KEY_STORE_PASSWORD} -storepass ${KEY_STORE_PASSWORD}

# Create the trust store.
keytool -keystore ${GENERIC_TRUSTSTORE} -alias CARoot -importcert -file ${ROOT_CA_CERT} -keypass ${TRUST_STORE_PASSWORD} -storepass ${TRUST_STORE_PASSWORD} -noprompt