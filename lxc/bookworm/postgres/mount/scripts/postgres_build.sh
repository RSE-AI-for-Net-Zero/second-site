#!/bin/bash

set -eux

BIN_PATH="/usr/lib/postgresql/15/bin"
CONFIG_PATH="/etc/postgresql/15/main/postgresql.conf"

apt-get update && \
    apt-get install -y --no-install-recommends postgresql && \
    sed -ri "s/^#?(listen_addresses)\s*=\s*\S+.*/\1 = '*'/" ${CONFIG_PATH} && \
    grep -e "^listen_addresses = '*'" ${CONFIG_PATH}

echo """
     export PATH=${PATH}:${BIN_PATH}
""" | tee -a /etc/bash.bashrc

echo $'host\tall\tall\t10.0.3.1/24\ttrust' | tee -a /etc/postgresql/15/main/pg_hba.conf

systemctl restart postgresql

##############################################
# Test installation
# 1. create a test database (as postgres user)
# 2. run python script
#
#su postgres
#createdb testdb
#
##############################################





