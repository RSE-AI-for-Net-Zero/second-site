CONFIG_ROOT="../lxc_config.conf"
NAME="rabbitmq"
export RABBIT_USER='second-site'
export RABBIT_PASSWD='generate_me_instead'


echo $'\n'"lxc.mount.entry = ${PWD}/mount home/ none bind 0 0" \
    | cat ${CONFIG_ROOT} -\
    | tee -a rabbit.conf

source ../create_container.sh 

create_container rabbitmq rabbit.conf && \
    rm -f rabbit.conf && \
    systemd-run --user --scope -p "Delegate=yes" -- lxc-start -n ${FULL_NAME} && \
    lxc-attach -n ${FULL_NAME} -- /home/build/rabbitmq_build.sh && \
    RABBIT_IPV4=`lxc-ls --fancy --fancy-format "NAME,STATE,IPV4" | grep "rabbitmq_debian_bookworm_amd64" | cut -d ' ' -f 3` &&\
    export RABBIT_IPV4    





