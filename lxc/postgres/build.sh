#!/bin/bash

#lxc-create -n postgres12 -t download -- -d debian -r bullseye -a amd64

#from https://github.com/docker-library/postgres/blob/master/12/bullseye/Dockerfile
#only changes documented here

#We're not setting postgres uid and gid explicitly - just have to query /etc/group and /etc/passwd if
# these are needed, e.g.

#grep "postgres" /etc/group | cut 

set -eux; \
    groupadd -r postgres; \
    useradd -r -g postgres --home-dir=/var/lib/postgresql --shell=/bin/bash postgres; \
    mkdir -p /var/lib/postgresql; \
    chown -R postgres:postgres /var/lib/postgresql

set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
	    gnupg \
	    less;
    rm -rf /var/lib/apt/lists/*

#building this as an lxc unprivileged container, so no sudo step-down, and so no gosu
set -eux; \
    apt-get update; apt-get install -y --no-install-recommends locales; rm -rf /var/lib/apt/lists/*; \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen; \
    locale-gen; \
    locale -a | grep 'en_US.utf8'

export LANG=en_US.utf8

set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
	    libnss-wrapper \
	    xz-utils \
	    zstd \
    ; \
    rm -rf /var/lib/apt/lists/*
    
set -ex; \
# pub   4096R/ACCC4CF8 2011-10-13 [expires: 2019-07-02]
#       Key fingerprint = B97B 0AFC AA1A 47F0 44F2  44A0 7FCC 7D46 ACCC 4CF8
# uid                  PostgreSQL Debian Repository
key='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8'; \
    export GNUPGHOME="$(mktemp -d)"; \
    mkdir -p /usr/local/share/keyrings/; \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
    gpg --batch --export --armor "$key" > /usr/local/share/keyrings/postgres.gpg.asc; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME"

export PG_MAJOR=12
export PATH=$PATH:/usr/lib/postgresql/$PG_MAJOR/bin
export PG_VERSION=12.19-1.pgdg110+1

set -ex; \
    export PYTHONDONTWRITEBYTECODE=1; \
    dpkgArch="$(dpkg --print-architecture)"; \
    aptRepo="[ signed-by=/usr/local/share/keyrings/postgres.gpg.asc ] http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main $PG_MAJOR"; \
    case "$dpkgArch" in amd64 | arm64 | ppc64el | s390x) \

	    echo "deb $aptRepo" > /etc/apt/sources.list.d/pgdg.list; \
		apt-get update; \
		     ;; \
		*) \
echo "deb-src $aptRepo" > /etc/apt/sources.list.d/pgdg.list; \
			\
			savedAptMark="$(apt-mark showmanual)"; \
			\
			tempDir="$(mktemp -d)"; \
			cd "$tempDir"; \
			\
# create a temporary local APT repo to install from (so that dependency resolution can be handled by APT, as it should be)
			apt-get update; \
			apt-get install -y --no-install-recommends dpkg-dev; \
			echo "deb [ trusted=yes ] file://$tempDir ./" > /etc/apt/sources.list.d/temp.list; \
			_update_repo() { \
				dpkg-scanpackages . > Packages; \
# work around the following APT issue by using "Acquire::GzipIndexes=false" (overriding "/etc/apt/apt.conf.d/docker-gzip-indexes")
#   Could not open file /var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages - open (13: Permission denied)
#   ...
#   E: Failed to fetch store:/var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages  Could not open file /var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages - open (13: Permission denied)
				apt-get -o Acquire::GzipIndexes=false update; \
			}; \
			_update_repo; \
			\
# build .deb files from upstream's source packages (which are verified by apt-get)
			nproc="$(nproc)"; \
			export DEB_BUILD_OPTIONS="nocheck parallel=$nproc"; \
# we have to build postgresql-common first because postgresql-$PG_MAJOR shares "debian/rules" logic with it: https://salsa.debian.org/postgresql/postgresql/-/commit/99f44476e258cae6bf9e919219fa2c5414fa2876
# (and it "Depends: pgdg-keyring")
			apt-get build-dep -y postgresql-common pgdg-keyring; \
			apt-get source --compile postgresql-common pgdg-keyring; \
			_update_repo; \
			apt-get build-dep -y "postgresql-$PG_MAJOR=$PG_VERSION"; \
			apt-get source --compile "postgresql-$PG_MAJOR=$PG_VERSION"; \
			\
# we don't remove APT lists here because they get re-downloaded and removed later
			\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
# (which is done after we install the built packages so we don't have to redownload any overlapping dependencies)
			apt-mark showmanual | xargs apt-mark auto > /dev/null; \
			apt-mark manual $savedAptMark; \
			\
			ls -lAFh; \
			_update_repo; \
			grep '^Package: ' Packages; \
			cd /; \
			;; \
	esac;

apt-get install -y --no-install-recommends postgresql-common; \
sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf; \
apt-get install -y --no-install-recommends \
	"postgresql-$PG_MAJOR=$PG_VERSION"; \
rm -rf /var/lib/apt/lists/*; \

if [ -n "$tempDir" ]; then \
    apt-get purge -y --auto-remove; \
    rm -rf "$tempDir" /etc/apt/sources.list.d/temp.list; \
    fi; \
    
find /usr -name '*.pyc' -type f -exec bash -c 'for pyc; do dpkg -S "$pyc" &> /dev/null || rm -vf "$pyc"; done' -- '{}' +; postgres --version

. ./build2.sh
. ./build3.sh
