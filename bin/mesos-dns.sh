#!/usr/bin/env bash

sudo docker run --net=host -d -v "/etc/mesos-dns/config.json:/config.json" mesosphere/mesos-dns /mesos-dns -config=/config.json