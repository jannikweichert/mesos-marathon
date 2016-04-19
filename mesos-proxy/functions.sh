#!/usr/bin/env bash

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
