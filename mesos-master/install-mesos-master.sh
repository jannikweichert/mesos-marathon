#!/bin/bash
set -e

if [ $# -ne 5 ]
then
    echo "Usage: install-mesos-master master1-IP master2-IP master3-IP masterNumber"
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
            echo "Adding $IP to your $RESOLV_CONF";
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
    masterNumber=$4
    internal_ip="${args[$masterNumber-1]}"
echo "
        Internal IP of Master 1: $master1_ip
        Internal IP of Master 2: $master2_ip
        Internal IP of Master 3: $master3_ip
        I am Master number $masterNumber, so my internal IP is: $internal_ip
        Mesos will be bound to: $external_ip"

        # Set static variables
        master1_hostname="master-01"
        master2_hostname="master-02"
        master3_hostname="master-03"

        quorum=2
        path_to_zoo_cfg="/etc/zookeeper/conf/zoo.cfg"
        mesos_master_quorum_path="/etc/mesos-master/quorum"
        mesos_master_ip_path="/etc/mesos-master/ip"
        mesos_master_ip=$internal_ip
        mesos_master_hostname_path="/etc/mesos-master/hostname"
        mesos_master_zookeeper_path="/etc/mesos/zk"
        mesos_zookeeper_url="zk://$master1_hostname:2181,$master2_hostname:2181,$master3_hostname:2181/mesos"

        marathon_conf_path="/etc/marathon/conf"
	    marathon_hostname_path="$marathon_conf_path/hostname"
	    marathon_hostname=$internal_ip
        marathon_zookeeper_master_path="$marathon_conf_path/master"
        marathon_zookeeper_path="$marathon_conf_path/zk"

        echo "Configure Hostnames"
        addhost $master1_ip $master1_hostname
        addhost $master2_ip $master2_hostname
        addhost $master3_ip $master3_hostname

        # Do the magic
        echo "Update Packages..."
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
        DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
        CODENAME=$(lsb_release -cs)

        echo "Set Codename to trusty so that we can download mesosphere"
        export CODENAME=trusty
        echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
        # Add Dependency for java 8"
        sudo add-apt-repository -y ppa:webupd8team/java
        sudo apt-get -y update

	    # Do no annoy us with silly questions, Oracle!
        echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
        echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections

        echo "Download Java 8"
        sudo apt-get -y install oracle-java8-installer

	    echo "Download mesosphere"
        sudo apt-get -y install mesosphere
        echo "Setup Zookeeper Connection Info for Mesos"
        echo "$mesos_zookeeper_url" | tee /etc/mesos/zk

        echo "Configure the Master Servers Zookeeper Configuration"
	    echo "$masterNumber" | sudo tee /etc/zookeeper/conf/myid
        # Uncomment
        sudo sed -i "s/#server/server/g" $path_to_zoo_cfg
        sudo sed -i "s/zookeeper1/$master1_hostname/g" $path_to_zoo_cfg
        sudo sed -i "s/zookeeper2/$master2_hostname/g" $path_to_zoo_cfg
        sudo sed -i "s/zookeeper3/$master3_hostname/g" $path_to_zoo_cfg

        echo "Configure Mesos on the Master Servers"
        echo "Set quorum"
        echo $quorum | sudo tee $mesos_master_quorum_path
        echo "Configure the Hostname and IP Address"
        echo $mesos_master_ip | sudo tee $mesos_master_ip_path
        echo $mesos_master_ip | sudo tee $mesos_master_hostname_path

        echo "Configure Marathon on the Master Servers"
        sudo mkdir -p $marathon_conf_path
        echo $marathon_hostname | sudo tee $marathon_hostname_path

        echo "Let Marathon connect to zookeeper"
        sudo cp $mesos_master_zookeeper_path $marathon_zookeeper_master_path

        echo "Let Marathon store own state information in zookeeper"
        # Copy existing zookeeper file
        sudo cp $marathon_zookeeper_master_path $marathon_zookeeper_path
        # Replace /mesos with /marathon
        sudo sed -i "s/mesos/marathon/g" $marathon_zookeeper_path

        echo "Configure Service Init Rules and Restart Services"
        # Make shure, master server is only runnign Mesos master process and not slave process
        # echo "Ensuring no slave processes are running"
        # sudo stop mesos-slave
        echo "Ensuring that server doesn't start the slave process at boot"
        echo echo manual | sudo tee /etc/init/mesos-slave.override


        echo "Install Docker"
        sudo apt-get install -y docker.io

        sudo apt-get install -y apt-transport-https ca-certificates
        sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
        echo "deb https://apt.dockerproject.org/repo ubuntu-${CODENAME} main" | sudo tee /etc/apt/sources.list.d/docker.list
        sudo apt-get update
        sudo apt-get purge lxc-docker
        sudo apt-cache policy docker-engine
        sudo apt-get install -y linux-image-extra-$(uname -r)
        sudo apt-get install -y apparmor
        sudo apt-get install -y docker-engine
        sudo apt-get install -y docker.io

        echo "Start Zookeeper to set up master elections"
        sudo start zookeeper & true
        echo "Start Mesos Master"
        sudo start mesos-master & true
        echo "Start Marathon"
        sudo start marathon & true

        echo "I'm done.
                Visit Mesos: http://$mesos_master_ip:5050
                Visit Marathon: http://$marathon_hostname:8080
                "
        exit 0
    fi


