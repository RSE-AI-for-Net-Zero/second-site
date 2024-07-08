CONFIG_ROOT="../lxc_config.conf"
NAME="rabbitmq"
export RABBIT_USER='second-site'
export RABBIT_PASSWD='generate_me_instead'


echo $'\n'"lxc.mount.entry = ${PWD}/mount home/ none bind 0 0" \
    | cat ${CONFIG_ROOT} -\
    | tee -a ${NAME}.conf

echo $'\n'"lxc.mount.entry = ${PWD}/../../certs var/lib/misc none bind,ro 0 0" \
    | tee -a ${NAME}.conf

source ../create_container.sh 

create_container ${NAME} ${NAME}.conf && \
    #lxc will store the container config somewhere
    rm -f ${NAME}.conf && \ 
    systemd-run --user --scope -p "Delegate=yes" -- lxc-start -n ${FULL_NAME} && \
    lxc-attach -n ${FULL_NAME} -- /home/scripts/rabbitmq_build.sh && \
    RABBIT_IPV4=`lxc-ls --fancy --fancy-format "NAME,STATE,IPV4" | grep "rabbitmq_debian_bookworm_amd64" | cut -d ' ' -f 3` &&\
    export RABBIT_IPV4    





