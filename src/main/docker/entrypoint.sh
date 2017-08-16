#!/bin/sh

if [ "$1" = 'cassandra-reaper' ]; then
    set -x
    su-exec reaper /usr/local/bin/append-persistence.sh
    exec su-exec reaper java ${JAVA_OPTS} -jar \
        /usr/local/lib/cassandra-reaper.jar server /etc/cassandra-reaper.yml
fi

exec "$@"
