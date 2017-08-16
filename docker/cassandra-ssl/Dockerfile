FROM cassandra:3.11

ENV WORKDIR /root
WORKDIR ${WORKDIR}
ARG KEY_STORE_PWD
ARG TRUST_STORE_PWD

# Set password for SSL stores used when calling nodetool
COPY nodetool-ssl.properties ${WORKDIR}/.cassandra/nodetool-ssl.properties
RUN sed -ie "s/KEYSTORE_PASSWORD/${KEY_STORE_PWD}/g" ${WORKDIR}/.cassandra/nodetool-ssl.properties \
    && sed -ie "s/TRUSTSTORE_PASSWORD/${TRUST_STORE_PWD}/g" ${WORKDIR}/.cassandra/nodetool-ssl.properties

# Set JVM SSL encryption options for Cassandra
RUN sed -ie 's/#JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=true"/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=true"/g' /etc/cassandra/cassandra-env.sh \
    && sed -ie 's/#JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.need.client.auth=true"/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.need.client.auth=true"/g' /etc/cassandra/cassandra-env.sh \
    && sed -ie 's/#JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.enabled.protocols=<enabled-protocols>"/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.enabled.protocols=TLSv1.2,TLSv1.1,TLSv1"/g' /etc/cassandra/cassandra-env.sh \
    && sed -ie 's/#JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.enabled.cipher.suites=<enabled-cipher-suites>"/JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl.enabled.cipher.suites=TLS_RSA_WITH_AES_256_CBC_SHA"/g' /etc/cassandra/cassandra-env.sh \
    && sed -ie "s/#JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.keyStore=\/path\/to\/keystore\"/JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.keyStore=\/etc\/ssl\/node-server-keystore\.jks\"/g" /etc/cassandra/cassandra-env.sh \
    && sed -ie "s/#JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.keyStorePassword=<keystore-password>\"/JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.keyStorePassword=${KEY_STORE_PWD}\"/g" /etc/cassandra/cassandra-env.sh \
    && sed -ie "s/#JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.trustStore=\/path\/to\/truststore\"/JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.trustStore=\/etc\/ssl\/generic-server-truststore\.jks\"/g" /etc/cassandra/cassandra-env.sh \
    && sed -ie "s/#JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.trustStorePassword=<truststore-password>\"/JVM_OPTS=\"\$JVM_OPTS -Djavax.net.ssl.trustStorePassword=${TRUST_STORE_PWD}\"/g" /etc/cassandra/cassandra-env.sh \
    && echo 'JVM_OPTS="$JVM_OPTS -Dcassandra.consistent.rangemovement=false"' >> /etc/cassandra/cassandra-env.sh

# copy entry point
COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160
CMD ["cassandra", "-f"]