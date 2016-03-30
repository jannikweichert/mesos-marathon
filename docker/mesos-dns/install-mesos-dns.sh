#!/usr/bin/env bash
set -e

if [ $# -ne 3 ]
then
    echo "Usage: install-mesos-dns master1_hostname master2_hostname master3_hostname"
else

    master1_hostname=$1
    master2_hostname=$2
    master3_hostname=$3

    mesos_zookeeper_url="zk://$master1_hostname:2181,$master2_hostname:2181,$master3_hostname:2181/mesos"
    mesos_dns_config="/etc/mesos-dns/config.json"

    echo "Get Mesos-DNS"
    curl -L https://github.com/mesosphere/mesos-dns/releases/download/v0.5.2/mesos-dns-v0.5.2-linux-amd64 > /usr/local/bin/mesos-dns
    # Make it executable
    chmod +x /usr/local/bin/mesos-dns
    echo "Create Mesos-DNS Config"
    mkdir -p /etc/mesos-dns
    echo "{
      \"zk\": \"$mesos_zookeeper_url\",
      \"refreshSeconds\": 60,
      \"ttl\": 60,
      \"domain\": \"mesos\",
      \"port\": 53,
      \"resolvers\": [
        \"169.254.169.254\", \"10.0.0.1\"
      ],
      \"timeout\": 5,
      \"email\": \"root.mesos-dns.mesos\"
    }" | tee ${mesos_dns_config}

    fi