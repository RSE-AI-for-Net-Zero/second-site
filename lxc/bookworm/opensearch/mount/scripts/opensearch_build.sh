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

    echo "GPG key: ${GPG_SIGNATURE} - verified"

    
   

	


