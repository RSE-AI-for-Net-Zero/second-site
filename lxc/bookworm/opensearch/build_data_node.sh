# Build follows the steps described here
# https://opensearch.org/docs/latest/install-and-configure/install-opensearch/debian/
# "Install OpenSeach from an APT repository"

# Mounts an external data volume into container (for a data node)

NAME=$1 #"opensearch"
CONFIG_ROOT=$2 #"../lxc_config.conf"
DATA_MNT=$3 #/home/leeb/data

export OPENSEARCH_VERSION="2.15.0"
export OPENSEARCH_INITIAL_ADMIN_PASSWORD="cHange_Me_@!22"
export GPG_SIGNATURE="c5b7 4989 65ef d1c2 924b a9d5 39d3 1987 9310 d3fc"


echo $'\n'"lxc.mount.entry = ${PWD}/mount home/ none bind 0 0"\
     $'\n'"lxc.mount.entry = ${DATA_MNT} home/data none bind,create=dir 0 0"\
    | cat ${CONFIG_ROOT} -\
    | tee -a ${NAME}.conf

source ../create_container.sh

create_container ${NAME} ${NAME}.conf && \
    #lxc will store the container config somewhere
    rm -f ${NAME}.conf && \ 
systemd-run --user --scope -p "Delegate=yes" -- lxc-start -n ${FULL_NAME} && \
systemd-run --user --scope -p "Delegate=yes" -- lxc-attach -n ${FULL_NAME} --clear-env \
	       --keep-var OPENSEARCH_VERSION \
	       --keep-var OPENSEARCH_INITIAL_ADMIN_PASSWORD \
	       --keep-var GPG_SIGNATURE \
	       -- /home/scripts/opensearch_build.sh

    
