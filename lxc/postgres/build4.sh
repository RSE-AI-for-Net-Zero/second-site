mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql && chmod 3777 /var/run/postgresql

export PGDATA=/var/lib/postgresql/data
# this 1777 will be replaced by 0700 at runtime (allows semi-arbitrary "--user" values)
mkdir -p "$PGDATA" && chown -R postgres:postgres "$PGDATA" && chmod 1777 "$PGDATA"
#VOLUME /var/lib/postgresql/data

#COPY docker-entrypoint.sh docker-ensure-initdb.sh /usr/local/bin/
#RUN ln -sT docker-ensure-initdb.sh /usr/local/bin/docker-enforce-initdb.sh
#ENTRYPOINT ["docker-entrypoint.sh"]
