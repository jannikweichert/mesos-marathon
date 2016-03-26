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
RUN apt-get -y install mesosphere

RUN echo "Configure Marathon on the Master Servers"
RUN sudo mkdir -p "/etc/marathon/conf"
RUN echo "192.168.99.100" | sudo tee "/etc/marathon/conf/hostname"

EXPOSE 5050
EXPOSE 8080
ADD ./run.sh
CMD ["run.sh"]
