FROM phusion/baseimage:0.9.18
MAINTAINER Jannik Weichert<mail@jannikweichert.de>

RUN echo "deb http://repos.mesosphere.io/ubuntu/ trusty main" > /etc/apt/sources.list.d/mesosphere.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF

# Add Dependency for java 8"
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get -y update

# Do not annoy us with silly questions, Oracle!
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
RUN echo "Download Java 8"
RUN apt-get -y install oracle-java8-installer

RUN echo "Install mesosphere"
RUN apt-get install -y mesos

RUN echo "Remove unneeded Zookeeper"
RUN service zookeeper stop
RUN apt-get -y remove --purge zookeeper
# Disable mesos-master from any default configuration
RUN echo manual > /etc/init/mesos-master.override

EXPOSE 5050
ENTRYPOINT ["mesos-slave"]