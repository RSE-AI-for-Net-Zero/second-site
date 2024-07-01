set -ex;
apt-get update;
apt-get install -y --no-install-recommends \
	gnupg \
	less openssh-server;
rm -rf /var/lib/apt/lists/*;

# grab gosu for easy step-down from root
# https://github.com/tianon/gosu/releases
export GOSU_VERSION=1.17
set -eux;
savedAptMark="$(apt-mark showmanual)";
apt-get update;
apt-get install -y --no-install-recommends ca-certificates wget;
rm -rf /var/lib/apt/lists/*;
dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')";
wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch";
wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc";
export GNUPGHOME="$(mktemp -d)";
gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4;
gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu;
gpgconf --kill all;
rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc;
apt-mark auto '.*' > /dev/null;
[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null;
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;
chmod +x /usr/local/bin/gosu;
gosu --version;
gosu nobody true
