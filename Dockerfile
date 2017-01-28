FROM amazonlinux:2016.09

ENV PCRE_VERSION 8.40

RUN yum -y update && yum -y install wget gcc gcc-c++

# Download, configure and install PCRE
RUN wget -P /tmp https://ftp.pcre.org/pub/pcre/pcre-"${PCRE_VERSION}".tar.gz && \
    tar -xf /tmp/pcre-"${PCRE_VERSION}".tar.gz -C /tmp && \
    rm -f /tmp/pcre-"${PCRE_VERSION}".tar.gz
RUN cd /tmp/pcre-"${PCRE_VERSION}" && \
    ./configure --prefix=/usr/local/pcre && make && make install
