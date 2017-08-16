FROM cassandra-ssl

ENV WORKDIR /root
WORKDIR ${WORKDIR}

COPY nodetool-ssl.properties ${WORKDIR}/.cassandra/nodetool-ssl.properties

# create the reaper_db keyspace
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

# use a default replication factor of 1
CMD [""]