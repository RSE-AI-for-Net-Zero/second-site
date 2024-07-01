set -eux

apt-get update && \
    apt-get -y install lsb-release ca-certificates curl gnupg2 grep && \

curl -o- https://artifacts.opensearch.org/publickeys/opensearch.pgp |\
    gpg --dearmor --batch --yes -o /usr/share/keyrings/opensearch-keyring && \

echo """
deb [signed-by=/usr/share/keyrings/opensearch-keyring] https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/apt stable main""" \
    | tee /etc/apt/sources.list.d/opensearch-2.x.list && \
    apt-get update && \
    # OPENSEARCH_INITIAL_ADMIN_PASSWORD should be set in host environment
    #  and propagated to here (lxc-attach propagates environ. by default)
    apt-get install opensearch=${OPENSEARCH_VERSION} && \
    [ -n `gpg --no-default-keyring --keyring /usr/share/keyrings/opensearch-keyring \
     --fingerprint |\ grep --ignore-case ${GPG_SIGNATURE}` ] && \

    echo "GPG key: ${GPG_SIGNATURE} - verified" && \

    cp /etc/opensearch/opensearch.yml /etc/opensearch/opensearch.yml.tmp && \

    if [ -n  "`grep -r "network.host" /etc/opensearch/opensearch.yml.tmp`" ]; then
	sed -ri 's/^#+(network.host)\s*\S+.*/\1: 0.0.0.0/' /etc/opensearch/opensearch.yml.tmp
    else
	echo "network.host: 0.0.0.0" | tee -a /etc/opensearch/opensearch.yml.tmp
    fi &&\

    if [- n "`grep -r "discovery.type" /etc/opensearch/opensearch.yml.tmp`" ]; then
	sed -ri 's/^#+(discovery.type)\s*\S+.*/\1: single-node/' /etc/opensearch/opensearch.yml.tmp
    else
	echo "discovery.type: single-node" | tee -a /etc/opensearch/opensearch.yml.tmp
    fi  &&\

    if [- n "`grep -r "plugins.security.disabled" /etc/opensearch/opensearch.yml.tmp`" ]; then
	sed -r 's/^#+(plugins.security.disabled)\s*\S+.*/\1: false/' /etc/opensearch/opensearch.yml.tmp
    else
	echo "plugins.security.disabled: false" | tee -a /etc/opensearch/opensearch.yml.tmp
    fi &&\

    cp -f /etc/opensearch/opensearch.yml.tmp /etc/opensearch/opensearch.yml && \

    systemctl enable opensearch && \
    systemctl restart opensearch

   

	


