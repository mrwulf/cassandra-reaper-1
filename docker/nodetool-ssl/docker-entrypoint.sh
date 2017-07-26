#!/bin/bash

set -e

sed -ie "s/KEYSTORE_PASSWORD/${KEYSTORE_PASSWORD}/g" ${WORKDIR}/.cassandra/nodetool-ssl.properties
sed -ie "s/TRUSTSTORE_PASSWORD/${TRUSTSTORE_PASSWORD}/g" ${WORKDIR}/.cassandra/nodetool-ssl.properties

nodetool --host cassandra-ssl --username cassandraUser --password cassandraPass --ssl $1