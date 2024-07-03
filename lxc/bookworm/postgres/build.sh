CONFIG_ROOT="../lxc_config.conf"
NAME="postgres"

echo $'\n'"lxc.mount.entry = ${PWD}/mount home/ none bind 0 0" \
    | cat ${CONFIG_ROOT} -\
    | tee -a ${NAME}.conf


source ../create_container.sh 

create_container ${NAME} ${NAME}.conf && \
    #lxc will store the container config somewhere
    rm -f ${NAME}.conf && \ 
systemd-run --user --scope -p "Delegate=yes" -- lxc-start -n ${FULL_NAME} && \
    lxc-attach -n ${FULL_NAME} -- /home/scripts/postgres_build.sh





