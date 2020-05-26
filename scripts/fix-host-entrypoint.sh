#!/usr/bin/env sh

# Linux Docker engine does not have `host.docker.internal` IP defined in /etc/hosts file as does Docker for Mac:
# https://docs.docker.com/docker-for-mac/networking/#use-cases-and-workarounds
#
# This script (entrypoint) sets it, if it is not set yet, and should only be used for testing purposes.

HOST_DOMAIN="host.docker.internal"
ping -q -c1 ${HOST_DOMAIN} > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    HOST_IP=$(ip route | awk 'NR==1 {print $3}')
    echo -e "${HOST_IP}\t${HOST_DOMAIN}" >> /etc/hosts
fi

exec /docker-entrypoint.sh "$@"
