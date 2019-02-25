FROM maven:3.6-jdk-8-alpine

MAINTAINER pjpires@gmail.com

RUN apk add --update \
        linux-headers build-base autoconf automake libtool apr-util apr-util-dev git cmake ninja go openssl

VOLUME /output

ADD compile.sh /compile.sh
RUN chmod +x /compile.sh
CMD /compile.sh
