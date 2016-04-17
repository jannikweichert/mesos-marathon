#!/usr/bin/env bash
  scp mesos-master/install-mesos-master.sh do-master-one:./
  scp mesos-master/install-mesos-master.sh do-master-two:./
  scp mesos-master/install-mesos-master.sh do-master-three:./

  scp mesos-slave/install-mesos-slave.sh do-slave-one:./
  scp mesos-slave/install-mesos-slave.sh do-slave-two:./
  scp mesos-slave/install-mesos-slave.sh do-slave-three:./

  scp mesos-dns/install-mesos-dns.sh do-slave-one:./



