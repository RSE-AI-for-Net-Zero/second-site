#### lxc-attach -n test -- apt-get install -y rabbitmq-server

set -eux

apt-get update &&\
    apt-get install -y --no-install-recommends rabbitmq-server

##################################################################
#/etc/default/rabbitmq-server
#/etc/rabbitmq/rabbitmq-env.conf
#
# ----------------------------------------------------------------
# rabbitmq-env.conf defaults:
# ----------------------------------------------------------------
#
# binds to all interfaces (IPv4 & 6) on port 5672, nodename RABBIT
# leaving these as they are
##################################################################


# the two config files are not created by packages, therefore
# add these if extra config required

#[ -f /etc/rabbitmq/rabbitmq.conf ] || touch /etc/rabbitmq/rabbitmq.conf
#[ -f /etc/rabbitmq/advanced.config ] || touch /etc/rabbitmq/advanced.config

# Create user
rabbitmqctl add_user ${RABBIT_USER} ${RABBIT_PASSWD}

# Create a virtual host
rabbitmqctl add_vhost vh1

# Set tags
rabbitmqctl set_user_tags ${RABBIT_USER} administrator

# Set permissions - allow everything
rabbitmqctl set_permissions --vhost vh1 ${RABBIT_USER} ".*" ".*" ".*"



