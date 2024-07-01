DISTR="debian"
RELEA="bookworm"
ARCHE="amd64"


am_i_root ()
{
    if [ `id -u` -eq 0 ]; then
	echo "You might be root. Exiting.";
	exit 1;
    fi
}

create_container ()
{
    #create_container CONTAINER_NAME
    am_i_root
    FULL_NAME=$1"_"${DISTR}"_"${RELEA}"_"${ARCHE}
    CONFIG=$2
    lxc-create -n $FULL_NAME -t download -f ${CONFIG} -- -d ${DISTR} -r ${RELEA} -a ${ARCHE}
}

