FROM fedora:25

RUN dnf -y update
RUN dnf -y install @development-tools java-1.8.0-openjdk-devel autoconf automake libtool git wget openssl-devel glibc-devel imake
RUN dnf -y install apr apr-devel
RUN dnf -y install file cmake
RUN dnf -y update
#ARG NETTY_TCNATIVE_TAG=netty-tcnative-parent-2.0.0.Final
#ENV NETTY_TCNATIVE_TAG $NETTY_TCNATIVE_TAG
#ENV CC ”gcc -fPIC”
#ENV CXX ”g++ -fPIC”
#ENV MAVEN_VERSION 3.5.0
ENV MAVEN_HOME /usr/share/maven

RUN cd /usr/share ; \
        wget -q http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz -O - | tar xzf - ;\
        mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven ;\
        ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

VOLUME /output

ADD compile.sh /compile.sh
RUN chmod +x /compile.sh
CMD /compile.sh