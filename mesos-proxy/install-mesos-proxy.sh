#!/usr/bin/env bash
if [ $# -ne 3 ]
then
    echo "Usage: install-mesos-proxy master1-IP master2-IP master3-IP"
    exit 1
fi

DIR="."
source "$DIR/functions.sh"

##################################################################
# Set Variables

args=($@)
master1_ip=$1
master2_ip=$2
master3_ip=$3

##################################################################
# Set static variables

master1_hostname="master-01"
master2_hostname="master-02"
master3_hostname="master-03"

##################################################################
# Install Docker

apt-get install docker.io

##################################################################
# Configure Hostnames

addhost "$master1_ip" "$master1_hostname"
addhost "$master2_ip" "$master2_hostname"
addhost "$master3_ip" "$master3_hostname"

exit 0

