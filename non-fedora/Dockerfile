FROM ubuntu:16.04

RUN apt-get update && apt-get -y install openjdk-8-jdk wget git curl
RUN apt-get -y install build-essential autoconf automake libtool
RUN apt-get -y install libapr1 libapr1-dev
RUN apt-get -y install openssl libssl-dev

#ARG NETTY_TCNATIVE_TAG=netty-tcnative-parent-2.0.0.Final
#ENV NETTY_TCNATIVE_TAG $NETTY_TCNATIVE_TAG
ENV MAVEN_VERSION 3.5.0
ENV MAVEN_HOME /usr/share/maven

RUN cd /usr/share ; \
        wget -q http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz -O - | tar xzf - ;\
        mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven ;\
        ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

VOLUME /output

ADD compile.sh /compile.sh
RUN chmod +x /compile.sh
CMD /compile.sh