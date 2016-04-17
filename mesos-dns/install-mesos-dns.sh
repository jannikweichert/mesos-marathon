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
    mesos_dns_path="/etc/mesos-dns"
    mesos_dns_config="$mesos_dns_path/config.json"

    echo "Get Mesos-DNS"
    curl -s -L https://github.com/mesosphere/mesos-dns/releases/download/v0.5.2/mesos-dns-v0.5.2-linux-amd64 > /usr/local/bin/mesos-dns
    # Make it executable
    chmod +x /usr/local/bin/mesos-dns
    echo "Writing Mesos-DNS Config to $mesos_dns_config"
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

    echo "Done. Start mesos-dns with: sudo mesos-dns -config=$mesos_dns_config"
    echo "Better: Start Mesos-DNS with Marathon, so it will be relaunched immediately on failures."
    echo "Use the command above and set the following constraint: hostname, CLUSTER, `hostname`"
    fi
