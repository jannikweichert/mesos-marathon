#!/usr/bin/env bash
if [ $# -ne 4 ]
then
    echo "Usage: install-mesos-slave master1 master2 master3 mesosdns_host"
else
    # Declare Functions
    addhost() {
        IP=$1
        HOSTNAME=$2
        # PATH TO YOUR HOSTS FILE
        ETC_HOSTS=/etc/hosts

        HOST_LINE="$IP\t$HOSTNAME"
        if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
            then
                echo "$HOSTNAME already exists : $(grep $HOSTNAME $ETC_HOSTS)"
            else
                echo "Adding $HOSTNAME to your $ETC_HOSTS";
                sudo sed -i "/127.0.0.1 localhost/a$HOST_LINE" $ETC_HOSTS
                if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
                    then
                        echo "$HOSTNAME was added succesfully \n $(grep $HOSTNAME /etc/hosts)";
                    else
                        echo "Failed to Add $HOSTNAME, Try again!";
                fi
        fi
    }

    addnameserver() {
        IP=$1
        RESOLV_CONF=/etc/resolv.conf

        NAMESERVER_LINE="nameserver $IP"
        if [ -n "$(grep $IP $RESOLV_CONF)" ]
            then
                echo "Nameserver entry already exists: $(grep $IP $RESOLV_CONF)"
            else
                echo "Adding $IP to your $RESOLV_CONF";
                sudo sed -i "1s/^/$NAMESERVER_LINE\n/" $RESOLV_CONF
                 if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
                    then
                        echo "$IP was added succesfully: $(grep $IP $RESOLV_CONF)";
                    else
                        echo "Failed to Add $IP, Try again!";
                fi
            fi
    }

    # Set Variables
    args=($@)
    master1_ip=$1
    master2_ip=$2
    master3_ip=$3
    mesos_dns_host=$4

    echo "
        Internal IP of Master 1: $master1_ip
        Internal IP of Master 2: $master2_ip
        Internal IP of Master 3: $master3_ip
        Host of Mesos-DNS: $mesos_dns_host"


    # Set static variables
    master1_hostname="master-01"
    master2_hostname="master-02"
    master3_hostname="master-03"

    # Resolve hostname to internal ip, so that slave registers correctly at master
    # See also: http://stackoverflow.com/a/27836414/1490673
    internal_ip=$(ifconfig eth1 | grep "inet addr" | cut -f2 -d: | cut -f1 -d " ")
    hostname=$(hostname)
    sed -i "s/127.0.1.1/$internal_ip/g" /etc/hosts

    # Configure Hostnames
    addhost $master1_ip $master1_hostname
    addhost $master2_ip $master2_hostname
    addhost $master3_ip $master3_hostname

    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
    DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
    CODENAME=$(lsb_release -cs)

    # Add the repository
    echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | \
    sudo tee /etc/apt/sources.list.d/mesosphere.list
    sudo apt-get -y update
    sudo apt-get -y install mesos

    #Disable ZooKeeper
    sudo service zookeeper stop
    sudo sh -c "echo manual > /etc/init/zookeeper.override"

    #Disable Mesos Master
    sudo service mesos-master stop
    sudo sh -c "echo manual > /etc/init/mesos-master.override"

    # Setup Zookeeper url for mesos-master detection
    echo "zk://master-01:2181,master-02:2181,master-03:2181/mesos" | tee /etc/mesos/zk

    # Configure Mesos-DNS as Nameserver
    addnameserver $mesos_dns_host

    echo "Install Docker"
    sudo apt-get install -y docker.io

    echo "Start Mesos Slave"
    sudo service mesos-slave restart
fi